Shader "OutLineEffect/DrawEffectOutLine"
{
    Properties
    {
        [Header(1. Base Color Option)]
        [Space]
        _BaseColor   ("Base Color",     Color)           = (1,1,1,1)

        [Header(2. Painted Texture Option)]
        [Space]
        _PaintedTex  ("Pained Texture", 2D)              = "white" {}

        [Header(3. OutLine Option)]
        [Space]
        _OutLineColor("OutLine Color",  Color)           = (0,0,0,0)
        _OutLineWidth("OutLine Width",  Range(0.000, 1)) = 0.01
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue"      = "Transparent"
        }

        // [First Pass] _ Base Texture or Color Draw

        cull   back
        zwrite on

        Stencil
        {
            Ref  1
            Pass Replace
        }

        CGPROGRAM
        #pragma surface surf Lambert Fullforwardshadows alpha:blend 
        #pragma target 3.0

        float4    _BaseColor;
        sampler2D _PaintedTex;

        struct Input
        {
            float2 uv_PaintedTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 baseTex   = tex2D(_PaintedTex, IN.uv_PaintedTex);
            
            o.Emission = baseTex.rgb * _BaseColor.rgb;
            o.Alpha    = _BaseColor.a;
        }
        ENDCG

        // [Second Pass] _ OutLine Draw

        cull   front
        zwrite off

        Stencil
        {
            Ref 1
            Comp NotEqual
        }

        CGPROGRAM

        #pragma surface surf NoLight vertex:vert noshadow noambient 
        #pragma target 3.0

        float4 _OutLineColor;
        float  _OutLineWidth;

        void vert(inout appdata_full v)
        {
            v.vertex.xyz += v.normal.xyz * _OutLineWidth;
        }

        struct Input
        {
            float4 color;
        };


        void surf(Input IN, inout SurfaceOutput o)
        {

        }

        float4 LightingNoLight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(_OutLineColor.rgb, _OutLineColor.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}