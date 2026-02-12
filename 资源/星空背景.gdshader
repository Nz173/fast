shader_type canvas_item;

## 优化的星空背景 Shader
## 优化点：减少 FBM 迭代次数，优化噪声计算

uniform vec4 bg_color : source_color = vec4(0.02, 0.02, 0.08, 1.0);
uniform vec4 nebula_color : source_color = vec4(0.2, 0.1, 0.4, 0.3);
uniform float nebula_intensity : hint_range(0.0, 5.0) = 3.0;  ## 星云强度
uniform float star_density : hint_range(0.90, 0.995) = 0.98;   ## 星星密度

// 优化的伪随机函数
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 优化的噪声函数 - 使用更少的计算
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // 使用平滑插值
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    // 四个角的随机值
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    // 双线性插值
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// 优化的分形布朗运动 - 从 5 次减少到 3 次迭代
float fbm(vec2 st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    
    // 优化：减少迭代次数，移除矩阵旋转以节省计算
    for (int i = 0; i < 3; ++i) {
        v += a * noise(st);
        st = st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void fragment() {
    vec2 uv = UV;
    
    // 背景底色
    vec3 color = bg_color.rgb;
    
    // 动态星云效果 - 简化计算
    float t = TIME * 0.05;
    vec2 q = vec2(
        fbm(uv + t * 0.1),
        fbm(uv + vec2(1.0))
    );
    
    vec2 r = vec2(
        fbm(uv + q + vec2(1.7, 9.2) + t * 0.15),
        fbm(uv + q + vec2(8.3, 2.8) + t * 0.126)
    );
    
    float f = fbm(uv + r * 0.5);  // 减少 r 的影响
    
    // 混合星云颜色
    color = mix(color, nebula_color.rgb, f * f * nebula_color.a * nebula_intensity);
    
    // 修正宽高比
    vec2 st = uv;
    st.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
    
    // 优化的星星层 - 减少循环开销
    for(float i = 1.0; i < 4.0; i += 1.0) {
        vec2 grid_uv = st * (10.0 * i) + vec2(TIME * (0.02 * i), 0.0);
        vec2 grid_id = floor(grid_uv);
        float rnd = random(grid_id);
        
        if (rnd > star_density) {
            vec2 center = grid_id + vec2(0.5);
            float dist = length(grid_uv - center);
            float star_brightness = 1.0 - smoothstep(0.0, 0.2, dist);
            
            // 闪烁效果
            float twinkle = 0.5 + 0.5 * sin(TIME * (2.0 + rnd * 5.0) + rnd * 100.0);
            star_brightness *= twinkle;
            
            // 远处星星更暗
            color += vec3(star_brightness) * (0.5 + 0.5 / i);
        }
    }
    
    // 暗角效果
    float vignette = 1.0 - distance(uv, vec2(0.5)) * 0.8;
    color *= vignette;
    
    COLOR = vec4(color, 1.0);
}
