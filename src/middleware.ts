import { clerkMiddleware } from '@clerk/nextjs/server';

// ✅ Initialize Clerk middleware
export default clerkMiddleware();

// ✅ Add config to ensure Clerk runs on correct routes
export const config = {
  matcher: [
    // Run Clerk on ALL routes except Next.js internals and static files
    '/((?!_next|.*\\..*).*)',
    // Always run for API routes
    '/(api|trpc)(.*)',
  ],
};
