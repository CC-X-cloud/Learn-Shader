Shader "Unlit/DIffuse reflact Pixel"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            float4 _Diffuse;
           struct a2v{
               float4 vertex:POSITION;
                float3 normal:NORMAL;
           };
           struct v2f{
               float4 pos:SV_POSITION;
               float3 worldNormal : TEXCOORD0;
               };
               v2f vert(a2v v){
                   v2f o;
                   o.pos = UnityObjectToClipPos(v.vertex);
                   o.worldNormal = mul((float3x3)unity_ObjectToWorld, v.normal);
                   return o;
               }
               fixed4 frag(v2f i): SV_TARGET{
                i.worldNormal = normalize(i.worldNormal);
                fixed3 ambinet = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 WorldRayDirection = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, WorldRayDirection));
                fixed3 color = ambinet + diffuse;
                return fixed4(color, 1);
               }

            ENDCG
        }
    }
}
