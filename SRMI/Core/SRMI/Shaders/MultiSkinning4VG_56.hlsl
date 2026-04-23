#define VERTEX_COUNT IniParams[0].x
#define POSE_ID IniParams[0].y

Texture1D<float4> IniParams : register(t120);

cbuffer cb0_struct : register(b0) { uint4 cb0[6]; }

struct t0_t {
    float3 position;
    float3 normal;
    float4 tangent;
    float4 tangent1;
};
struct t1_t {
    float4 weight;
    uint4  index;
};

StructuredBuffer<t0_t> t0 : register(t20);
StructuredBuffer<t1_t> t1 : register(t21);
// Requires Texture Resources to have the `misc_flags = buffer_allow_raw_views`
// ByteAddressBuffer t0 : register(t20);
// ByteAddressBuffer t1 : register(t21);
StructuredBuffer<float4x4> t2 : register(t22);

RWByteAddressBuffer u0 : register(u0);
RWByteAddressBuffer u1 : register(u1);
RWByteAddressBuffer u2 : register(u2);
RWByteAddressBuffer u3 : register(u3);
RWByteAddressBuffer u4 : register(u4);
RWByteAddressBuffer u5 : register(u5);
RWByteAddressBuffer u6 : register(u6);

[numthreads(64, 1, 1)]
void main(uint3 vThreadID : SV_DispatchThreadID){
    if (vThreadID.x >= (uint)VERTEX_COUNT) return;
    if (POSE_ID < 0 || POSE_ID > 29) return;

    uint4 id;
    uint slot = (uint)POSE_ID % 10;
    uint offset = cb0[slot < 4 ? 4 : 5][slot % 4];

    t0_t pos = t0[vThreadID.x];
    t1_t blend = t1[vThreadID.x];
    // Requires Texture Resources to have the `misc_flags = buffer_allow_raw_views`
    // id = vThreadID.x*32 + uint4(0,16,0,0);
    // t1_t blend = {
    //     asfloat(t1.Load4(id.x)), 
    //     t1.Load4(id.y)
    // };
    // id = vThreadID.x*40 + uint4(0,12,24,0);
    // t0_t pos = {
    //     asfloat(t0.Load3(id.x)), 
    //     asfloat(t0.Load3(id.y)), 
    //     asfloat(t0.Load4(id.z))
    // };

    float4 pose_0 = (
        //blend.weight.x * asfloat(t2.Load4( blend.index.x + offset))
        + blend.weight.x * t2[blend.index.x + offset][0].xyzw
        + blend.weight.y * t2[blend.index.y + offset][0].xyzw
        + blend.weight.z * t2[blend.index.z + offset][0].xyzw
        + blend.weight.w * t2[blend.index.w + offset][0].xyzw
    );

    float4 pose_1 = (
        + blend.weight.x * t2[blend.index.x + offset][1].xyzw
        + blend.weight.y * t2[blend.index.y + offset][1].xyzw
        + blend.weight.z * t2[blend.index.z + offset][1].xyzw
        + blend.weight.w * t2[blend.index.w + offset][1].xyzw
    );

    float4 pose_2 = (
        + blend.weight.x * t2[blend.index.x + offset][2].xyzw
        + blend.weight.y * t2[blend.index.y + offset][2].xyzw
        + blend.weight.z * t2[blend.index.z + offset][2].xyzw
        + blend.weight.w * t2[blend.index.w + offset][2].xyzw
    );

    float4x3 mat_43 = {
        pose_0.x, pose_1.x, pose_2.x,
        pose_0.y, pose_1.y, pose_2.y,
        pose_0.z, pose_1.z, pose_2.z,
        pose_0.w, pose_1.w, pose_2.w
    };

    float3x3 mat_33 = {
        mat_43[0],
        mat_43[1],
        mat_43[2]
    };

    float4 _position, _normal, _tangent, _tangent1;
    _position.xyz = mul(float4(pos.position, 1),   mat_43);
    _normal.xyz   = normalize(mul(pos.normal.xyz,  mat_33));
    _tangent.xyz  = normalize(mul(pos.tangent.xyz, mat_33));
    _tangent.w = pos.tangent.w;
    _tangent1.xyz = normalize(mul(pos.tangent1.xyz, mat_33));
    _tangent1.w = pos.tangent1.w;

    id = vThreadID.x*56 + uint4(0,12,24,40);
    [forcecase]
    switch(slot) {
        case 0:
            u0.Store3(id.x, asuint(_position.xyz));
            u0.Store3(id.y, asuint(_normal.xyz));
            u0.Store4(id.z, asuint(_tangent.xyzw));
            u0.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 1:
            u1.Store3(id.x, asuint(_position.xyz));
            u1.Store3(id.y, asuint(_normal.xyz));
            u1.Store4(id.z, asuint(_tangent.xyzw));
            u1.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 2:
            u2.Store3(id.x, asuint(_position.xyz));
            u2.Store3(id.y, asuint(_normal.xyz));
            u2.Store4(id.z, asuint(_tangent.xyzw));
            u2.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 3:
            u3.Store3(id.x, asuint(_position.xyz));
            u3.Store3(id.y, asuint(_normal.xyz));
            u3.Store4(id.z, asuint(_tangent.xyzw));
            u3.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 4:
            u4.Store3(id.x, asuint(_position.xyz));
            u4.Store3(id.y, asuint(_normal.xyz));
            u4.Store4(id.z, asuint(_tangent.xyzw));
            u4.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 5:
            u5.Store3(id.x, asuint(_position.xyz));
            u5.Store3(id.y, asuint(_normal.xyz));
            u5.Store4(id.z, asuint(_tangent.xyzw));
            u5.Store4(id.w, asuint(_tangent1.xyzw));
            break;
        case 6:
            u6.Store3(id.x, asuint(_position.xyz));
            u6.Store3(id.y, asuint(_normal.xyz));
            u6.Store4(id.z, asuint(_tangent.xyzw));
            u6.Store4(id.w, asuint(_tangent1.xyzw));
            break;
    }
    return;
}