"use client"

import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { Card, CardContent } from "@/components/ui/card"
import { Trophy, Calendar, Target, TrendingUp, User } from "lucide-react"
import { useTournament } from "@/contexts/tournament-context"

interface PlayerHistoryModalProps {
  playerId: string
  onClose: () => void
}

export default function PlayerHistoryModal({ playerId, onClose }: PlayerHistoryModalProps) {
  const { players, matches } = useTournament()

  const player = players.find((p) => p.id === playerId)
  const playerMatches = matches
    .filter((match) => match.player1Id === playerId || match.player2Id === playerId)
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())

  if (!player) return null

  const wins = playerMatches.filter((match) => match.winnerId === playerId).length
  const losses = playerMatches.length - wins
  const winRate = playerMatches.length > 0 ? (wins / playerMatches.length) * 100 : 0

  let setsWon = 0
  let setsLost = 0
  let gamesWon = 0
  let gamesLost = 0

  playerMatches.forEach((match) => {
    if (match.player1Id === playerId) {
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

  const getOpponentName = (match: any) => {
    const opponentId = match.player1Id === playerId ? match.player2Id : match.player1Id
    return players.find((p) => p.id === opponentId)?.name || "Oponente desconocido"
  }

  const getMatchResult = (match: any) => {
    const isWinner = match.winnerId === playerId
    const playerSets = match.player1Id === playerId ? match.player1Sets : match.player2Sets
    const opponentSets = match.player1Id === playerId ? match.player2Sets : match.player1Sets
    const playerGames = match.player1Id === playerId ? match.player1Games : match.player2Games
    const opponentGames = match.player1Id === playerId ? match.player2Games : match.player1Games

    // Construir resultado completo set por set
    let resultadoCompleto = ""

    // Set 1
    if (match.player1Id === playerId) {
      resultadoCompleto += `${match.set1Player1Games}-${match.set1Player2Games}`
    } else {
      resultadoCompleto += `${match.set1Player2Games}-${match.set1Player1Games}`
    }

    // Set 2
    if (match.player1Id === playerId) {
      resultadoCompleto += `, ${match.set2Player1Games}-${match.set2Player2Games}`
    } else {
      resultadoCompleto += `, ${match.set2Player2Games}-${match.set2Player1Games}`
    }

    // Set 3 (si existe)
    if ((match.set3Player1Games > 0 || match.set3Player2Games > 0) && match.player1Id === playerId) {
      resultadoCompleto += `, ${match.set3Player1Games}-${match.set3Player2Games}`
    } else if (match.set3Player1Games > 0 || match.set3Player2Games > 0) {
      resultadoCompleto += `, ${match.set3Player2Games}-${match.set3Player1Games}`
    }

    return {
      isWinner,
      score: `${playerSets}-${opponentSets}`,
      playerSets,
      opponentSets,
      playerGames,
      opponentGames,
      resultadoCompleto,
      isSuperTiebreak: match.isSuperTiebreak,
    }
  }

  return (
    <Dialog open={true} onOpenChange={onClose}>
      <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-3 text-2xl">
            <User className="h-6 w-6 text-blue-600" />
            {player.name}
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* Estadísticas Generales */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <Card>
              <CardContent className="p-4 text-center">
                <Trophy className="h-8 w-8 text-green-600 mx-auto mb-2" />
                <div className="text-2xl font-bold text-green-600">{wins}</div>
                <div className="text-sm text-gray-500">Victorias</div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4 text-center">
                <Target className="h-8 w-8 text-red-500 mx-auto mb-2" />
                <div className="text-2xl font-bold text-red-500">{losses}</div>
                <div className="text-sm text-gray-500">Derrotas</div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4 text-center">
                <TrendingUp className="h-8 w-8 text-blue-600 mx-auto mb-2" />
                <div className="text-2xl font-bold text-blue-600">{winRate.toFixed(0)}%</div>
                <div className="text-sm text-gray-500">Efectividad</div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="p-4 text-center">
                <Calendar className="h-8 w-8 text-purple-600 mx-auto mb-2" />
                <div className="text-2xl font-bold text-purple-600">
                  {setsWon}-{setsLost}
                </div>
                <div className="text-sm text-gray-500">Sets</div>
              </CardContent>
            </Card>
          </div>

          {/* Información del Jugador */}
          <Card>
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-semibold text-lg">Información del Jugador</h3>
                </div>
                <div className="text-right">
                  <div className="text-sm text-gray-500">Partidos Jugados</div>
                  <div className="text-2xl font-bold">{playerMatches.length}</div>
                </div>
              </div>
              <div className="mt-4 grid grid-cols-2 gap-4">
                <div>
                  <div className="text-sm text-gray-500">Sets</div>
                  <div className="text-lg font-medium">
                    {setsWon}-{setsLost}{" "}
                    <span className="text-sm text-gray-500">
                      ({setsWon - setsLost > 0 ? "+" : ""}
                      {setsWon - setsLost})
                    </span>
                  </div>
                </div>
                <div>
                  <div className="text-sm text-gray-500">Games</div>
                  <div className="text-lg font-medium">
                    {gamesWon}-{gamesLost}{" "}
                    <span className="text-sm text-gray-500">
                      ({gamesWon - gamesLost > 0 ? "+" : ""}
                      {gamesWon - gamesLost})
                    </span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Historial de Partidos */}
          <div>
            <h3 className="text-lg font-semibold mb-4 flex items-center gap-2">
              <Calendar className="h-5 w-5" />
              Historial de Partidos
            </h3>

            {playerMatches.length === 0 ? (
              <Card>
                <CardContent className="p-8 text-center">
                  <Calendar className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                  <p className="text-gray-500">No hay partidos registrados</p>
                </CardContent>
              </Card>
            ) : (
              <div className="space-y-3">
                {playerMatches.map((match, index) => {
                  const result = getMatchResult(match)
                  const opponentName = getOpponentName(match)

                  return (
                    <Card
                      key={match.id}
                      className={`border-l-4 ${result.isWinner ? "border-l-green-500" : "border-l-red-500"}`}
                    >
                      <CardContent className="p-4">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center space-x-3">
                            <div
                              className={`w-3 h-3 rounded-full ${result.isWinner ? "bg-green-500" : "bg-red-500"}`}
                            />
                            <div>
                              <p className="font-medium">vs {opponentName}</p>
                              <p className="text-sm text-gray-500">
                                {new Date(match.date).toLocaleDateString("es-ES", {
                                  year: "numeric",
                                  month: "short",
                                  day: "numeric",
                                })}
                              </p>
                            </div>
                          </div>

                          <div className="text-right">
                            <div className="text-lg font-bold">Sets: {result.score}</div>
                            <div className="text-sm text-gray-600">{result.resultadoCompleto}</div>
                            <div className="flex gap-2 mt-1 justify-end">
                              <Badge variant={result.isWinner ? "default" : "secondary"}>
                                {result.isWinner ? "Victoria" : "Derrota"}
                              </Badge>
                              {result.isSuperTiebreak && <Badge variant="outline">Super Tiebreak</Badge>}
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
