"use client";

export default function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center h-screen text-center p-6">
      <h1 className="text-4xl font-bold mb-2">Page Not Found</h1>
      <p className="text-muted-foreground mb-4">
        The page you are looking for does not exist.
      </p>
    </div>
  );
}
