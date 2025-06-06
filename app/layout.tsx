import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { TournamentProvider } from "@/contexts/tournament-context"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "Tennis Pro - Torneo de Tenis",
  description: "Sistema profesional de gestión de torneos de tenis",
    generator: 'v0.dev'
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <TournamentProvider>{children}</TournamentProvider>
      </body>
    </html>
  )
}
