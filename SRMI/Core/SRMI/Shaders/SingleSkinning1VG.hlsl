struct pos_struct {
    float3 position;
    float3 normal;
    float4 tangent;
};
struct blend_struct {
    uint index;
    float weight;
};
cbuffer cb0_struct : register(b0) {
    uint4 cb0[6];
}

StructuredBuffer<pos_struct> pos_buf : register(t20);
StructuredBuffer<blend_struct> blend_buf : register(t21);
StructuredBuffer<float4x4> skinning : register(t22);
RWStructuredBuffer<pos_struct> result : register(u7);

Texture1D<float4> IniParams : register(t120);
#define VERTEX_COUNT IniParams[0].x
#define POSE_ID IniParams[0].y

[numthreads(64, 1, 1)]
void main(uint3 vThreadID: SV_DispatchThreadID) {
    if (vThreadID.x >= (uint)VERTEX_COUNT) {
        return;
    }
    // POSE_ID Encodes the slot ID for the pose buffer and which shader it corresponds to
    // 1 -> Single Pose No SK
    // 2 -> Single Pose Yes SK
    // 10 - 19 -> Multipose No SK
    // 20 - 29 -> Multipose Yes SK
    // slot 0 cb04.x 
    // slot 1 cb04.y
    // slot 2 cb04.z
    // slot 3 cb04.w
    // slot 4 cb05.x
    // slot 5 cb05.y
    // slot 6 cb05.z
    // slot 7 cb05.w

    uint offset = 0;
    uint slot = 0;

    // if (POSE_ID < 1 || POSE_ID > 29) {
    //     // invalid- we leave
    //     return;
    // }

    if (POSE_ID >= 10) {
        // slot = (uint)POSE_ID % 10;
        // offset = cb0[slot < 4 ? 4 : 5][slot % 4];
        slot = POSE_ID - 30;
        if (slot == 0) {
            offset = cb0[4].x;
        } else if (slot == 1) {
            offset = cb0[4].y;
        } else if (slot == 2) {
            offset = cb0[4].z;
        } else if (slot == 3) {
            offset = cb0[4].w;
        } else if (slot == 4) {
            offset = cb0[5].x;
        } else if (slot == 5) {
            offset = cb0[5].y;
        } else if (slot == 6) {
            offset = cb0[5].z;
        } else if (slot == 7) {
            offset = cb0[5].w;
        }
    }

    pos_struct pos = pos_buf[vThreadID.x];
    blend_struct blend = blend_buf[vThreadID.x];

    float4 pose_0 = (1 * skinning[blend.index.x + offset][0].xyzw);
    float4 pose_1 = (1 * skinning[blend.index.x + offset][1].xyzw);
    float4 pose_2 = (1 * skinning[blend.index.x + offset][2].xyzw);

    float4x3 mat_4x3 = {
        pose_0.x, pose_1.x, pose_2.x,
        pose_0.y, pose_1.y, pose_2.y,
        pose_0.z, pose_1.z, pose_2.z,
        pose_0.w, pose_1.w, pose_2.w
    };
    float3x3 mat_3x3 = {
        mat_4x3[0],
        mat_4x3[1],
        mat_4x3[2]
    };

    float3 _position = mul(float4(pos.position, 1), mat_4x3);
    float3 _normal = normalize(mul(pos.normal.xyz, mat_3x3));
    float3 _tangent = normalize(mul(pos.tangent.xyz, mat_3x3));

    result[vThreadID.x].position.xyz = _position.xyz;
    result[vThreadID.x].normal.xyz = _normal.xyz;
    result[vThreadID.x].tangent.xyzw = float4(_tangent.xyz, pos.tangent.w);

    return;
}
