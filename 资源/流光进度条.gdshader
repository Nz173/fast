shader_type canvas_item;

## 流光进度条 Shader - 带斜向流光效果的进度条

uniform vec4 fill_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);
uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform float shine_speed : hint_range(0.0, 10.0) = 3.0;  ## 流光速度
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.5;  ## 流光强度

void fragment() {
    // 剪裁未填充部分 - 使用 step 替代 if 以提高 GPU 性能
    float fill_mask = step(UV.x, progress);
    if (fill_mask < 0.5) {
        discard;
    }
    
    // 基础颜色
    vec3 color = fill_color.rgb;
    
    // 斜向流光 - 使用 sin 函数创建流动效果
    float shine = abs(sin(UV.x * 5.0 - TIME * shine_speed + UV.y * 2.0));
    shine = smoothstep(0.0, 0.2, shine) * shine_intensity;
    
    // 混合流光颜色
    color = mix(color, shine_color.rgb, shine * shine_color.a);
    
    COLOR = vec4(color, fill_color.a);
}
