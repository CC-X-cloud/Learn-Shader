Shader "Unlit/NormalMapTanfentSpaceMat"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumMap("Normal Map", 2D) = "bump" {}
        _BumScale("Normal Scale", Range(0,2)) = 1
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
                sampler2D _BumMap;
                float4 _BumMap_ST;
                float _BumScale;
                fixed4 _Specular;
                float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightdir : TEXCOORD1;
                float3 viewdir : TEXCOORD2;
                
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumMap_ST.xy + _BumMap_ST.zw;

                //TANGENT_SPACE_ROTATION;
                float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);

                o.lightdir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewdir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightdir);
                fixed3 tangentViewDir = normalize(i.viewdir);

                fixed4 packednormal = tex2D(_BumMap, i.uv.zw);
                fixed3 tangentnormal;

                tangentnormal.xy = (packednormal.xy * 2 - 1) * _BumScale;
                tangentnormal.z = sqrt(1 - saturate(dot(tangentnormal.xy, tangentnormal.xy)));

                tangentnormal = UnpackNormal(packednormal);
                tangentnormal.xy += _BumScale;
                tangentnormal = sqrt(1 - saturate(dot(tangentnormal.xy, tangentnormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                 
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentnormal, tangentLightDir));

                fixed3 halfdir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentnormal, halfdir)), _Gloss);

                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
