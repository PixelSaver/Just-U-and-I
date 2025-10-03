shader_type canvas_item;



void fragment()
{
    vec2 resolution = vec2(1.0) / TEXTURE_PIXEL_SIZE;
    vec2 uv = (UV * 2.0 - 1.0);
    uv.x *= resolution.x / resolution.y;

    // Zoom level
    float zoom = 8.0;
    uv *= zoom;

    // Parameter 'a' - animate from 0.01 to 1.0
    float a = 5.01 + sin(TIME*0.01)*10.;

    // Get polar coordinates of current pixel
    float theta = atan(uv.y, uv.x);
    float r = length(uv);

    // We need to check multiple "wraps" of theta since tan is periodic
    float minDist = 1e10;

    // Check multiple wraps of theta (accounting for atan only giving -pi to pi)
    for (int wrap = 0; wrap <= 100; wrap++) {
        float theta_wrapped = theta + float(wrap) * 2.0 * PI;

        // Only consider theta in our desired range [0, 100*pi]
        if (theta_wrapped >= 0.0 && theta_wrapped <= 100.0 * PI) {
            // Calculate expected r for this theta: r = tan(theta/(a*pi))
            float expectedR = tan(theta_wrapped / (a * PI));

            // Skip discontinuities where tan blows up
            if (abs(expectedR) < 1000.0) {
                // Distance between actual r and expected r
                float dist = abs(r - expectedR);
                minDist = min(minDist, dist);

                // Also check negative r (plots in opposite direction)
                float distNeg = abs(r - abs(expectedR));
                minDist = min(minDist, distNeg);
            }
        }

        // Also check negative wraps for the full curve
        float theta_neg = theta - float(wrap) * 2.0 * PI;
        if (theta_neg >= 0.0 && theta_neg <= 100.0 * PI) {
            float expectedR = tan(theta_neg / (a * PI));
            if (abs(expectedR) < 1000.0) {
                float dist = abs(r - expectedR);
                minDist = min(minDist, dist);
            }
        }
    }

    float d = minDist;

    // Create the line
    float thickness = 0.04 * zoom;
    float line = smoothstep(thickness, 0.0, d);

    // Background grid for reference
    vec2 grid = abs(fract(uv * 0.2) - 0.5);
    float gridLine = min(grid.x, grid.y);
    float gridVis = smoothstep(0.01, 0.0, gridLine) * 0.08;

    // Axes
    float axisX = smoothstep(0.02, 0.0, abs(uv.y)) * 0.2;
    float axisY = smoothstep(0.02, 0.0, abs(uv.x)) * 0.2;

    // Color the curve based on parameter a
    vec3 curveColor = vec3(1.0 - smoothstep(0.0, thickness, minDist));

    // Combine everything
    vec3 col = vec3(0.02, 0.02, 0.05); // Dark background
    col += gridVis; // Add subtle grid
    col += axisX + axisY; // Add axes
    col = mix(col, curveColor, line); // Add curve with animated color

    // Add glow effect
    float glow = exp(-d * 0.5) * 0.05;
    col += glow * curveColor;
	col *= vec3(0.7803921568627451, 0.34901960784313724, 0.8862745098039215);

	float alpha = 1.0 - smoothstep(0.0, 8.8, length(uv));

    COLOR = vec4(col, alpha);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
