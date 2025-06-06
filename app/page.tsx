"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Trophy, Medal, Award, User, Target } from "lucide-react"
import { useTournament } from "@/contexts/tournament-context"
import PlayerHistoryModal from "@/components/player-history-modal"
import Navigation from "@/components/navigation"

export default function HomePage() {
  const { players, matches } = useTournament()
  const [selectedPlayer, setSelectedPlayer] = useState<string | null>(null)

  // Calcular estadísticas de cada jugador con la nueva lógica
  const playerStats = players.map((player) => {
    const playerMatches = matches.filter((match) => match.player1Id === player.id || match.player2Id === player.id)

    const wins = playerMatches.filter((match) => match.winnerId === player.id).length
    const losses = playerMatches.length - wins
    const winRate = playerMatches.length > 0 ? (wins / playerMatches.length) * 100 : 0

    // Calcular sets y games según las nuevas reglas
    let setsWon = 0
    let setsLost = 0
    let gamesWon = 0
    let gamesLost = 0

    playerMatches.forEach((match) => {
      if (match.player1Id === player.id) {
        setsWon += match.player1Sets
        setsLost += match.player2Sets
        gamesWon += match.player1Games
        gamesLost += match.player2Games
      } else {
        setsWon += match.player2Sets
        setsLost += match.player1Sets
        gamesWon += match.player2Games
        gamesLost += match.player1Games
      }
    })

    return {
      ...player,
      wins,
      losses,
      winRate,
      setsWon,
      setsLost,
      setsDiff: setsWon - setsLost,
      gamesWon,
      gamesLost,
      gamesDiff: gamesWon - gamesLost,
      matchesPlayed: playerMatches.length,
    }
  })

  // Ordenar por partidos ganados y luego por diferencia de sets
  const sortedPlayers = playerStats.sort((a, b) => {
    if (b.wins !== a.wins) return b.wins - a.wins
    if (b.setsDiff !== a.setsDiff) return b.setsDiff - a.setsDiff
    return b.gamesDiff - a.gamesDiff
  })

  const getRankIcon = (position: number) => {
    switch (position) {
      case 1:
        return <Trophy className="h-5 w-5 text-yellow-500" />
      case 2:
        return <Medal className="h-5 w-5 text-gray-400" />
      case 3:
        return <Award className="h-5 w-5 text-amber-600" />
      default:
        return <span className="text-lg font-bold text-muted-foreground">#{position}</span>
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <Navigation />

      <div className="container mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Torneo de Tenis</h1>
          <p className="text-lg text-gray-600">Tabla de Posiciones</p>
        </div>

        <Card className="max-w-7xl mx-auto shadow-lg overflow-x-auto">
          <CardHeader className="bg-gradient-to-r from-green-600 to-blue-600 text-white">
            <CardTitle className="text-2xl text-center">Clasificación General</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {sortedPlayers.length === 0 ? (
              <div className="text-center py-12">
                <User className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500 text-lg">No hay jugadores registrados</p>
                <p className="text-gray-400">El administrador debe agregar jugadores para comenzar</p>
              </div>
            ) : (
              <div className="min-w-full">
                <table className="min-w-full divide-y divide-gray-200">
                  <thead className="bg-gray-50">
                    <tr>
                      <th
                        scope="col"
                        className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Pos
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Jugador
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        PJ
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        PG
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        PP
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Sets
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Dif Sets
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Games
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Dif Games
                      </th>
                      <th
                        scope="col"
                        className="px-3 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider"
                      >
                        Eficiencia
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {sortedPlayers.map((player, index) => (
                      <tr
                        key={player.id}
                        className="hover:bg-gray-50 transition-colors cursor-pointer"
                        onClick={() => setSelectedPlayer(player.id)}
                      >
                        <td className="px-3 py-4 whitespace-nowrap">
                          <div className="flex items-center justify-center">{getRankIcon(index + 1)}</div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap">
                          <div className="text-sm font-medium text-gray-900">{player.name}</div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div className="text-sm text-gray-900">{player.matchesPlayed}</div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div className="text-sm font-bold text-green-600">{player.wins}</div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div className="text-sm text-gray-900">{player.losses}</div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div className="text-sm text-gray-900">
                            {player.setsWon}-{player.setsLost}
                          </div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div
                            className={`text-sm font-medium ${player.setsDiff > 0 ? "text-green-600" : player.setsDiff < 0 ? "text-red-600" : "text-gray-600"}`}
                          >
                            {player.setsDiff > 0 ? "+" : ""}
                            {player.setsDiff}
                          </div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div className="text-sm text-gray-900">
                            {player.gamesWon}-{player.gamesLost}
                          </div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <div
                            className={`text-sm font-medium ${player.gamesDiff > 0 ? "text-green-600" : player.gamesDiff < 0 ? "text-red-600" : "text-gray-600"}`}
                          >
                            {player.gamesDiff > 0 ? "+" : ""}
                            {player.gamesDiff}
                          </div>
                        </td>
                        <td className="px-3 py-4 whitespace-nowrap text-center">
                          <Badge
                            variant={player.winRate >= 70 ? "default" : player.winRate >= 50 ? "secondary" : "outline"}
                          >
                            {player.winRate.toFixed(0)}%
                          </Badge>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>

        {sortedPlayers.length > 0 && (
          <div className="text-center mt-6">
            <p className="text-gray-600">
              <Target className="inline h-4 w-4 mr-1" />
              Haz clic en cualquier jugador para ver su historial completo
            </p>
          </div>
        )}
      </div>

      {selectedPlayer && <PlayerHistoryModal playerId={selectedPlayer} onClose={() => setSelectedPlayer(null)} />}
    </div>
  )
}
