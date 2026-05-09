// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Diffuse reflection Vertex"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            fixed4 _Diffuse;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 color : COLOR;
                float4 pos : SV_POSITION;
            };
            v2f vert(a2v v)
            {
                v2f o;
               o.pos = UnityObjectToClipPos(v.vertex);
               fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
               fixed3 worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));
               fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
               fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
               o.color = ambient + diffuse;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1);
            }

            ENDCG
        }
    }
                FallBack "Diffuse reflection"
}
