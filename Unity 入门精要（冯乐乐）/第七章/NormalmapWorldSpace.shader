// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/NormalmapWorldSpace"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumMap ("Normal Map", 2D) = "bump" {}
        _BumScal("Normal Scale", Range(0,2)) = 1
        _SPECULAR("Specular", Color) = (1,1,1,1)
        _GLOSS("Gloss", Range(8,256)) = 20
        
    }
    SubShader
    {
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            float4 _Color;
             sampler2D _MainTex;
             float4 _MainTex_ST;
             sampler2D _BumMap;
             float4 _BumMap_ST;
             float _BumScal;
             fixed4 _SPECULAR;
             float _GLOSS;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float4 tangent : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv: TEXCOORD0;
                float4 Ttow0 : TEXCOORD1;
                float4 Ttow1 : TEXCOORD2;
                 float4 Ttow2 : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumMap_ST.xy + _BumMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                o.Ttow0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
                o.Ttow1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
                o.Ttow2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.Ttow0.w, i.Ttow1.w, i.Ttow2.w);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumMap, i.uv.zw));
                bump.xy *= _BumScal;
                bump.z = sqrt(1 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3 (dot(i.Ttow0.xyz,bump),dot(i.Ttow1.xyz,bump),dot(i.Ttow2.xyz,bump)));
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));

                fixed3 halfvector = normalize(lightDir + viewDir);
                fixed3 specular = _SPECULAR.rgb * _LightColor0.rgb * pow(max(0, dot(bump, halfvector)), _GLOSS);

                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);

                
            }
            ENDCG
        }
    }
}
