Shader "Skybox/LatLong" {
Properties {
	_Tint ("Tint Color", Color) = (.5, .5, .5, .5)
	[Gamma] _Exposure ("Exposure", Range(0, 8)) = 1.0
	_MainTex ("LatLong (HDR)", 2D) = "grey" {}
}

SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
	Cull Off ZWrite Off

	Pass {

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		half4 _MainTex_HDR;
		half4 _Tint;
		half _Exposure;

		struct appdata_t {
			float4 vertex : POSITION;
		};

		struct v2f {
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
			fixed t : TEXCOORD1;
		};

		v2f vert (appdata_t v)
		{
			float3 d = normalize(v.vertex.xyz);
			v2f o;
			o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = float2(abs(atan2(d.z, d.x)), acos(-d.y)) / UNITY_PI;
			o.t = d.z * 0.5;
			return o;
		}

		fixed4 frag (v2f i) : SV_Target
		{
			float2 uv = float2((0.5 - ceil(i.t)) * i.uv.x, i.uv.y);
			half4 tex = tex2D (_MainTex, TRANSFORM_TEX(uv, _MainTex));
			half3 c = DecodeHDR (tex, _MainTex_HDR);
			c = c * _Tint.rgb * unity_ColorSpaceDouble.rgb;
			c *= _Exposure;
			return half4(c, 1);
		}
		ENDCG 
	}
} 	

Fallback Off

}
