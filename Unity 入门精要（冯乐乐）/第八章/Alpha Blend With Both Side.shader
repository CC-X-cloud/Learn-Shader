Shader "Unlit/Alpha Blend With Both Side"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _AlphaScale("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                  float3 WorldNormal = normalize(i.worldNormal);
                  float3 WorldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                  float3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb; 

                  float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                  float3 difuse = _LightColor0.rgb * albedo.rgb * max(0, dot(WorldNormal, WorldLightDir));
                  float3 color = ambient + difuse;
                  return float4(color, _Color.a * _AlphaScale);
            }
            ENDCG
            }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Cull Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                  float3 WorldNormal = normalize(i.worldNormal);
                  float3 WorldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                  float3 albedo = tex2D(_MainTex, i.uv) * _Color.rgb; 

                  float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                  float3 difuse = _LightColor0.rgb * albedo.rgb * max(0, dot(WorldNormal, WorldLightDir));
                  float3 color = ambient + difuse;
                  return float4(color, _Color.a * _AlphaScale);
            }
            ENDCG
        }
    }
    Fallback "Transparent/VertexLit"
}
