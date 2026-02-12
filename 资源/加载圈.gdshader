shader_type canvas_item;

## 加载圈 Shader - 旋转的环形加载动画

uniform vec4 base_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform float speed : hint_range(0.0, 10.0) = 2.0;           ## 旋转速度
uniform float inner_radius : hint_range(0.0, 0.5) = 0.35;    ## 内半径
uniform float outer_radius : hint_range(0.0, 0.5) = 0.5;     ## 外半径
uniform float glow_intensity : hint_range(1.0, 3.0) = 1.5;   ## 辉光强度

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    
    // 极坐标转换
    float radius = length(uv);
    float angle = atan(uv.y, uv.x);
    
    // 旋转动画
    float rot_angle = angle - TIME * speed;
    
    // 创建环形 - 使用平滑步进
    float inner_edge = inner_radius - 0.05;
    float outer_edge = outer_radius;
    float ring = smoothstep(inner_edge, inner_radius, radius) - 
                 smoothstep(outer_edge - 0.05, outer_edge, radius);
    
    // 尾迹渐变效果
    float normalized_angle = fract(-rot_angle / TWO_PI);
    float tail = smoothstep(0.0, 0.8, normalized_angle);
    
    // 组合透明度和颜色
    float alpha = ring * tail * base_color.a;
    vec3 glow = base_color.rgb * glow_intensity;
    
    COLOR = vec4(glow, alpha);
}
