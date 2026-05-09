 Shader "Unlit/Specular Vertex"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Gloss("Specular Value", Range(8,256)) = 20
        _Specular("Specular Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed _Gloss;
            fixed4 _Specular;
            fixed4 _Diffuse;

            struct a2v{
            fixed4 vertex:POSITION;
            fixed3 normal:NORMAL;
            };

            struct v2f
            {
                fixed4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                 o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 WorldRayDirection = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 Normal2World = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(Normal2World, WorldRayDirection));

                fixed3 reflactDir = normalize(reflect(-WorldRayDirection, Normal2World));
                fixed3 viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflactDir, viewDir)), _Gloss );
                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1);
            }
            

            ENDCG
        }
    }
    Fallback "Specular Vertex"
}
