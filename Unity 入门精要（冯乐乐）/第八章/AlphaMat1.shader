Shader "Custom/AlphaMat1"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5 
    }
    SubShader
    {
        Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        Pass{
            Tags{"LightMode" = "ForwardBase"}
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        float4 _Color;
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float _Cutoff;

        struct  a2v
        {
            float4 vertex :POSITION;
            float3 normal :NORMAL;
            float4 texcoord :TEXCOORD0;
        };
        struct  v2f
        {
            float4 pos : SV_POSITION;
            float3 worldnormal : NORMAL;
            float3 worldpos : TEXCOORD0;
            float2 uv : TEXCOORD1;
        };
        v2f vert(a2v v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldnormal = UnityObjectToWorldNormal(v.normal);
            o.worldpos = mul(unity_ObjectToWorld, v.vertex).xyz;
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            return o;
        }
        fixed4 frag(v2f i) : SV_Target
        {
            fixed3 WorldNormal = normalize(i.worldnormal);
            fixed3 WorldLightDir = normalize(UnityWorldSpaceLightDir(i.worldpos));

            fixed4 texColor = tex2D(_MainTex, i.uv);

            clip (texColor.a - _Cutoff);

            fixed3 albedo = texColor.rgb * _Color.rgb;
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
            fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(WorldNormal, WorldLightDir));
            return fixed4(ambient + diffuse, 1.0);
        }
        ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}
