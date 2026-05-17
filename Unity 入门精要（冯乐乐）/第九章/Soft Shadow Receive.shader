Shader "Unlit/Soft Shadow Receive"
{
    Properties
    {
        _Diffuse("Diffuse", Color) = (1,1,1,1)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(0,256)) = 20
    }
    SubShader
    {

        Pass
        {
            Name "Pass1"
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 WorldNormal : TEXCOORD0;
                float3 WorldPos : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal);
                o.WorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                //在base pass里接受阴影贴图
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //阴影计算
                fixed shadow = SHADOW_ATTENUATION(i);

                float3 WorldNormal = normalize(i.WorldNormal);
                float3 WorldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(WorldNormal,WorldLightDir))*shadow;

                float3 WorldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.WorldPos);
                float3 halfDir = normalize(WorldLightDir + WorldViewDir);

                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(halfDir,WorldNormal)),_Gloss)*shadow;

                //衰减率用来表现额外光照效果这里去掉也行
                float atten = 1.0;


                return fixed4(ambient + (diffuse + specular) * atten, 1);
                }
            ENDCG
        }
        //第二个pass用来处理额外的光照效果
        Pass{
            Name"Pass2"
            Tags{"LightMode" = "ForwardAdd"}

            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc" 
            #include "AutoLight.cginc"

            float4 _Diffuse;
            float4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 WorldNormal : TEXCOORD0;
                float3 WorldPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.WorldNormal = UnityObjectToWorldNormal(v.normal);
                o.WorldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 WorldNormal = normalize(i.WorldNormal);

                //关键点一：判断光源方式，世界光基本不做改变，额外光添加衰减率
                #ifdef USING_DIRECTIONAL_LIGHT
                float3 WorldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                float3 WorldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.WorldPos.xyz);
                #endif

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(WorldNormal,WorldLightDir));

                float3 WorldViewDir = normalize(_WorldSpaceCameraPos.xyz - i.WorldPos);
                float3 halfDir = normalize(WorldLightDir + WorldViewDir);

                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(halfDir,WorldNormal)),_Gloss);

                //关键点二：如果是额外光，计算额外光衰减UNITY_LIGHT_ATTENUATION来自宏 #include "AutoLight.cginc"
                //UNITY_LIGHT_ATTENUATION（返回值，结构体，世界空间中的点坐标）
                 #ifdef USING_DIRECTIONAL_LIGHT
                    float atten = 1.0;
                 #else
                    UNITY_LIGHT_ATTENUATION(atten, i, i.WorldPos);
                #endif
                    
                return fixed4((diffuse + specular)*atten,1);
            }
            ENDCG

        }
        Pass{
            Name"Shader"
            Tags{"LightMode" = "ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f{
                V2F_SHADOW_CASTER;
            };
            v2f vert(appdata_base v){
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }
            float4 frag (v2f i) : SV_TARGET{
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
            
        }
    }
    Fallback "Standard"
}
