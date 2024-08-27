import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import "@rainbow-me/rainbowkit/styles.css";
import { ThemeProvider } from "@/providers/theme-provider";
import Pancake from "@/components/Pancake";
import Navbar from "@/components/Navbar";
import WagmiProvider from "@/providers/wagmi-provider";
import { Toaster } from "@/components/ui/toaster";
import MobileNav from "@/components/MobileNav";
import Footer from "@/components/Footer";
const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Linkie - easy links, fast payments",
  description: "easy links, fast payments",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="dark"
          enableSystem
          disableTransitionOnChange
        >
          <WagmiProvider>
            <Pancake>
              <Navbar />
              <main className="px-4 py-4 mb-24 lg:py-0">{children}</main>
              <Toaster />
              <MobileNav />
              <Footer />
            </Pancake>
          </WagmiProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
