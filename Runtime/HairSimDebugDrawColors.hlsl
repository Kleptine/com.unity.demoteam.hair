#ifndef __HAIRSIMDEBUGDRAWCOLORS_HLSL__
#define __HAIRSIMDEBUGDRAWCOLORS_HLSL__

//----------------
// colors generic

// Rotates through several discrete colors, with a max of 'tiers'.
float3 ColorCycle(uint index, uint tiers)
{
	float t = frac(index / (float) tiers);

	// source: https://www.shadertoy.com/view/4ttfRn
	float3 c = 3.0 * float3(abs(t - 0.5), t.xx) - float3(1.5, 1.0, 2.0);
	return 1.0 - c * c;
}

float3 ColorRamp(uint index, uint tiers)
{
	float t = 1.0 - frac(index / (float) tiers);

	// source: https://www.shadertoy.com/view/4ttfRn
	float3 c = 2.0 * t - float3(0.0, 1.0, 2.0);
	return 1.0 - c * c;
}

//-------------------
// colors quantities

float3 ColorDensity(float rho)
{
	float above = saturate(rho - 1.0);
	return float3(saturate(rho), saturate(rho) - above, saturate(rho) - above);
}

float3 ColorDivergence(float div)
{
	if (div < 0.0)// inward flux increases pressure
		return saturate(abs(float3(div, div, 0.0)));
	else
		return saturate(abs(float3(0.0, div, div)));
}

float3 ColorPressure(float p)
{
	p *= 15.0;
	if (p > 0.0)
		return saturate(float3(frac(p), 0.0, 0.0));
	else
		return saturate(float3(0.0, 0.0, frac(-p)));
}

float3 ColorGradient(float3 n)
{
	//return abs(n.zzz);

	float d = dot(n, n);
	if (d > 1e-12)
		return 0.5 + 0.5 * (n * rsqrt(d));
	else
		return 0.5;

	//return (0.5 + 0.5 * normalize(n.xzy));
}

float3 ColorVelocity(float3 v)
{
	return saturate(abs(float3(v.x, 0.0, -v.z)));
}

float3 ColorProbe(float3 s)
{
	return s;
}

// Returns a color from a thermal gradient based on the index and total number of tiers.
// 
// Index: The current level (0 to tiers-1)
// Tiers: Total number of levels (must be > 1 for full gradient)
// Returns: float3 RGB color (0.0 to 1.0)
float3 ColorHeatmap(uint index, uint tiers)
{
	// Safety check to prevent division by zero
	if (tiers <= 1) return float3(0.0, 0.0, 0.0);

	// Normalize index to 0.0 - 1.0 range
	float t = saturate((float)index / (float)(tiers - 1));

	// Define 5 distinct color stops for a "Cool to Hot" thermal look
	// These are chosen to avoid muddy blends in the transitions
	float3 c0 = float3(0.10, 0.10, 0.60); // Deep Blue (Coolest)
	float3 c1 = float3(0.10, 0.60, 0.70); // Cyan
	float3 c2 = float3(0.10, 0.70, 0.10); // Green
	float3 c3 = float3(0.90, 0.70, 0.10); // Yellow/Orange
	float3 c4 = float3(0.90, 0.10, 0.10); // Red (Hottest)

	// We have 4 intervals between 5 colors. Scale t to 0..4
	float scaledT = t * 4.0;
    
	// Determine which interval we are in using lerp for branching-free logic (mostly)
	// or simple conditional blending. For HLSL, step/lerp is efficient.
    
	float3 color;
	if (scaledT < 1.0)
	{
		color = lerp(c0, c1, scaledT);
	}
	else if (scaledT < 2.0)
	{
		color = lerp(c1, c2, scaledT - 1.0);
	}
	else if (scaledT < 3.0)
	{
		color = lerp(c2, c3, scaledT - 2.0);
	}
	else
	{
		color = lerp(c3, c4, scaledT - 3.0);
	}

	return color;
}

#endif//__HAIRSIMDEBUGDRAWCOLORS_HLSL__
