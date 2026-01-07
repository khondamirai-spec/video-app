import type { Metadata, Viewport } from "next";
import AnalyticsWrapper from "./components/AnalyticsWrapper";
import "./globals.css";

export const metadata: Metadata = {
  title: "Videx - Educational Videos",
  description: "Watch short educational videos with real view tracking",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: "#000000",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        {children}
        <AnalyticsWrapper />
      </body>
    </html>
  );
}
