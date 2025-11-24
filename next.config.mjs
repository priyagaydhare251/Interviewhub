/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    optimizePackageImports: ["convex"],
    serverActions: {
      allowedOrigins: ["*"],
    },
    serverMinification: false,
  },

  // Prevent Next.js from pre-rendering Convex pages
  generateBuildId: async () => {
    return "build";
  },

  output: "standalone",
  trailingSlash: false,
  reactStrictMode: true,
};

export default nextConfig;
