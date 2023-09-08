Shader "OutLineEffect/DrawEffectOutLine"
{
    Properties
    {
        [Header(1. Base Color Option)]
        [Space]
        _BaseColor   ("Base Color",      Color)           = (1,1,1,1)

        [Header(2. Painted Texture Option)]
        [Space]
        _PaintedTex  ("Painted Texture", 2D)              = "white" {}

        [Header(3. OutLine Option)]
        [Space]
        [MaterialToggle] 
        _IsEnabled   ("Actived",         Float)           = 0
        _OutLineColor("OutLine Color",   Color)           = (1,1,1,1)
        _OutLineWidth("OutLine Width",   Range(0.000, 1)) = 0.01
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
            fixed4 baseTex     = tex2D(_PaintedTex, IN.uv_PaintedTex);
            fixed4 resultColor = baseTex * _BaseColor;

            o.Emission = resultColor.rgb;
            o.Alpha    = resultColor.a;
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

        #pragma surface surf NoLight vertex:vert noshadow noambient alpha:blend 
        #pragma target 3.0

        float4 _OutLineColor;
        float  _OutLineWidth;
        float  _IsEnabled;

        void vert(inout appdata_full v)
        {
            v.vertex.xyz += v.normal.xyz * _OutLineWidth;
        }

        struct Input
        {
            float Color;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {

        }

        float4 LightingNoLight(SurfaceOutput s, float3 lightDir, float atten)
        {
            if (_IsEnabled > 0) { return float4(_OutLineColor.rgb, _OutLineColor.a); }
            else                { return float4(0, 0, 0, 0);                         }
        }
        ENDCG
    }
    FallBack "Diffuse"
}