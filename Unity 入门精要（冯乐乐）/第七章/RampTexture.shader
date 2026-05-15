// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/RampTexture"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _RampTex("Ramp Texture", 2D) = "white" {}
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(8,256)) = 20
    }
    SubShader
    {
        
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

             fixed4 _Color;
             sampler2D _RampTex;
             float4 _RampTex_ST;
             fixed4 _Specular;
             float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldnormal : TEXCOORD0;
                float3 worldpos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
                o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldnormal = normalize(i.worldnormal);
                fixed3 worldlightdir = normalize(UnityWorldSpaceLightDir(i.worldpos));
                fixed3 ambinet = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halflambert = dot(worldnormal,worldlightdir) * 0.5 + 0.5;
                fixed3 diffusecolor = tex2D(_RampTex,fixed2(halflambert,halflambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * diffusecolor;

                fixed3 viewdir = normalize (UnityWorldSpaceViewDir(i.worldpos));
                fixed3 halfdir = normalize(worldlightdir + viewdir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldnormal,halfdir)),_Gloss);
                return fixed4(diffuse + specular + ambinet, 1.0);
            }
            ENDCG
        }
    }
}
