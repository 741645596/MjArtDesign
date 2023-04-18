#ifndef ROLE_CORE_INCLUDED
#define ROLE_CORE_INCLUDED

// 头发各向异性高光
half HairSpecular(float3 hDirWS, float3 nDirWS, half specularWidth) {

    float hDotn = dot(hDirWS, nDirWS);
    float sinTH = (sqrt(1 - pow(hDotn, 2)));
    half dirAtten = smoothstep(-1, 0, hDotn);
    half specular = dirAtten * saturate(pow(sinTH, specularWidth));
    return (specular);
}




#endif // ROLE_CORE_INCLUDED