/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ["convex"],
    serverActions: {
      allowedOrigins: ["*"],
    },
  },

  // Disable pre-rendering that needs backend URLs
  output: "standalone",

  // Prevent Next.js static export (Convex incompatible)
  trailingSlash: false,
  reactStrictMode: true,

  // ⛔ Tell Next.js NOT to pre-render pages at build time
  images: { unoptimized: true },

  // THIS IS IMPORTANT
  env: {
    NEXT_PUBLIC_DISABLE_CONVEX_PRERENDER: "true",
  }
};

export default nextConfig;
