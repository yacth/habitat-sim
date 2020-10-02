// Copyright (c) Facebook, Inc. and its affiliates.
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

// ------------ input ------------------------
layout(location = ATTRIBUTE_LOCATION_POSITION) in highp vec4 vertexPosition;
layout(location = ATTRIBUTE_LOCATION_NORMAL) in highp vec3 vertexNormal;
#if defined(TEXTURED)
layout(location = ATTRIBUTE_LOCATION_TEXCOORD) in mediump vec2 vertexTexCoord;
#endif
#if defined(NORMAL_TEXTURE) && defined(PRECOMPUTED_TANGENT)
layout(location = ATTRIBUTE_LOCATION_TANGENT4) in highp vec4 vertexTangent;
#endif

// -------------- output ---------------------
// position, normal, tangent in camera space
out highp vec3 position;
out highp vec3 normal;
#if defined(TEXTURED)
out mediump vec2 texCoord;
#endif
#if defined(NORMAL_TEXTURE) && defined(PRECOMPUTED_TANGENT)
out highp vec3 tangent;
out highp vec3 biTangent;
#endif

// ------------ uniform ----------------------
uniform mat4 ModelViewMatrix;
uniform mat3 NormalMatrix;  // inverse transpose of 3x3 modelview matrix
uniform mat4 MVP;

#ifdef TEXTURE_TRANSFORMATION
uniform mediump mat3 textureMatrix
#ifndef GL_ES
    = mat3(1.0)
#endif
    ;
#endif

void main() {
  position = vec3(ModelViewMatrix * vertexPosition);
  normal = normalize(NormalMatrix * vertexNormal);
#if defined(TEXTURED)
  texCoord =
#if defined(TEXTURE_TRANSFORMATION)
      (textureMatrix * vec3(vertexTexCoord, 1.0)).xy;
#else
      vertexTexCoord;
#endif  // TEXTURE_TRANSFORMATION
#endif  // TEXTURED

#if defined(NORMAL_TEXTURE) && defined(PRECOMPUTED_TANGENT)
  tangent = normalize(NormalMatrix * vec3(vertexTangent));
  // Gram–Schmidt
  tangent = normalize(tangent - dot(tangent, normal) * normal);
  biTangent = normalize(cross(normal, tangent) * vertexTangent.w);
  // later in .frag, TBN will transform the normal perturbation
  // (read from normal map) from tangent space to camera space
#endif

  gl_Position = MVP * vec4(vertexPosition, 1.0);
}