"use client"

import { createContext, useContext, useEffect, useState, type ReactNode } from "react"

export interface Player {
  id: string
  name: string
}

// Actualizar la interfaz Match para manejar sets individuales
export interface Match {
  id: string
  player1Id: string
  player2Id: string
  // Set 1
  set1Player1Games: number
  set1Player2Games: number
  // Set 2
  set2Player1Games: number
  set2Player2Games: number
  // Set 3 (opcional - solo si hay empate 1-1)
  set3Player1Games: number
  set3Player2Games: number
  // Totales calculados
  player1Sets: number
  player2Sets: number
  player1Games: number
  player2Games: number
  isSuperTiebreak: boolean
  winnerId: string
  date: string
}

// Actualizar la interfaz para próximos partidos (sin ubicación)
export interface UpcomingMatch {
  id: string
  player1Id: string
  player2Id: string
  scheduledDate: string
  scheduledTime: string
}

interface TournamentContextType {
  players: Player[]
  matches: Match[]
  upcomingMatches: UpcomingMatch[]
  addPlayer: (name: string) => void
  removePlayer: (id: string) => void
  addMatch: (match: Omit<Match, "id" | "date">) => void
  removeMatch: (id: string) => void
  updateMatch: (id: string, match: Omit<Match, "date">) => void
  addUpcomingMatch: (match: Omit<UpcomingMatch, "id">) => void
  removeUpcomingMatch: (id: string) => void
}

const TournamentContext = createContext<TournamentContextType | undefined>(undefined)

export function TournamentProvider({ children }: { children: ReactNode }) {
  const [players, setPlayers] = useState<Player[]>([])
  const [matches, setMatches] = useState<Match[]>([])
  const [upcomingMatches, setUpcomingMatches] = useState<UpcomingMatch[]>([])

  useEffect(() => {
    const savedPlayers = localStorage.getItem("tournament-players")
    const savedMatches = localStorage.getItem("tournament-matches")
    const savedUpcomingMatches = localStorage.getItem("tournament-upcoming-matches")

    if (savedPlayers) {
      setPlayers(JSON.parse(savedPlayers))
    }

    if (savedMatches) {
      setMatches(JSON.parse(savedMatches))
    }

    if (savedUpcomingMatches) {
      setUpcomingMatches(JSON.parse(savedUpcomingMatches))
    }
  }, [])

  useEffect(() => {
    localStorage.setItem("tournament-players", JSON.stringify(players))
  }, [players])

  useEffect(() => {
    localStorage.setItem("tournament-matches", JSON.stringify(matches))
  }, [matches])

  useEffect(() => {
    localStorage.setItem("tournament-upcoming-matches", JSON.stringify(upcomingMatches))
  }, [upcomingMatches])

  const addPlayer = (name: string) => {
    const newPlayer: Player = {
      id: Date.now().toString(),
      name,
    }
    setPlayers((prev) => [...prev, newPlayer])
  }

  const removePlayer = (id: string) => {
    setPlayers((prev) => prev.filter((player) => player.id !== id))
    setMatches((prev) => prev.filter((match) => match.player1Id !== id && match.player2Id !== id))
    setUpcomingMatches((prev) => prev.filter((match) => match.player1Id !== id && match.player2Id !== id))
  }

  const addMatch = (matchData: Omit<Match, "id" | "date">) => {
    const newMatch: Match = {
      ...matchData,
      id: Date.now().toString(),
      date: new Date().toISOString(),
    }
    setMatches((prev) => [...prev, newMatch])
  }

  const removeMatch = (id: string) => {
    setMatches((prev) => prev.filter((match) => match.id !== id))
  }

  const updateMatch = (id: string, matchData: Omit<Match, "date">) => {
    setMatches((prev) =>
      prev.map((match) => {
        if (match.id === id) {
          return {
            ...match,
            ...matchData,
          }
        }
        return match
      }),
    )
  }

  const addUpcomingMatch = (matchData: Omit<UpcomingMatch, "id">) => {
    const newMatch: UpcomingMatch = {
      ...matchData,
      id: Date.now().toString(),
    }
    setUpcomingMatches((prev) => [...prev, newMatch])
  }

  const removeUpcomingMatch = (id: string) => {
    setUpcomingMatches((prev) => prev.filter((match) => match.id !== id))
  }

  return (
    <TournamentContext.Provider
      value={{
        players,
        matches,
        upcomingMatches,
        addPlayer,
        removePlayer,
        addMatch,
        removeMatch,
        updateMatch,
        addUpcomingMatch,
        removeUpcomingMatch,
      }}
    >
      {children}
    </TournamentContext.Provider>
  )
}

export function useTournament() {
  const context = useContext(TournamentContext)
  if (context === undefined) {
    throw new Error("useTournament must be used within a TournamentProvider")
  }
  return context
}
