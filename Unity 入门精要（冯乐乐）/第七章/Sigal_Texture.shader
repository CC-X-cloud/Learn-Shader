Shader "Unlit/Sigal_Texture"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8,256)) = 20
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

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };


            v2f vert (a2v  v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 worldnormal = normalize(i.worldNormal);
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed4 texColor = tex2D(_MainTex, i.uv) * _Color;
                fixed lambert = dot(worldnormal, lightDir)*0.5 + 0.5;

                fixed3 diffuse = texColor.rgb * _LightColor0.rgb * lambert;

                fixed3 halfvector = normalize(lightDir + normalize(_WorldSpaceCameraPos - i.worldPos));
                fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0, dot(worldnormal, halfvector)), _Gloss);

                fixed4 color = fixed4(ambient + diffuse + specular, texColor.a);

                return color;

            }
            ENDCG
        }
    }
}
