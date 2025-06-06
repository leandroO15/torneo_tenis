"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Calendar, Trophy, Users } from "lucide-react"
import { useTournament } from "@/contexts/tournament-context"
import Navigation from "@/components/navigation"

export default function ResultsPage() {
  const { players, matches } = useTournament()

  const getPlayerName = (playerId: string) => {
    return players.find((p) => p.id === playerId)?.name || "Jugador desconocido"
  }

  const sortedMatches = [...matches].sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <Navigation />

      <div className="container mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Resultados</h1>
          <p className="text-lg text-gray-600">Historial completo de partidos</p>
        </div>

        <Card className="max-w-4xl mx-auto shadow-lg">
          <CardHeader className="bg-gradient-to-r from-green-600 to-blue-600 text-white">
            <CardTitle className="text-2xl text-center flex items-center justify-center gap-2">
              <Trophy className="h-6 w-6" />
              Partidos Disputados
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {sortedMatches.length === 0 ? (
              <div className="text-center py-12">
                <Calendar className="h-16 w-16 text-gray-400 mx-auto mb-4" />
                <p className="text-gray-500 text-lg">No hay partidos registrados</p>
                <p className="text-gray-400">Los resultados aparecerán aquí cuando se jueguen partidos</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-200">
                {sortedMatches.map((match, index) => {
                  const player1Name = getPlayerName(match.player1Id)
                  const player2Name = getPlayerName(match.player2Id)
                  const winnerName = getPlayerName(match.winnerId)
                  const isPlayer1Winner = match.winnerId === match.player1Id

                  return (
                    <div key={match.id} className="p-6 hover:bg-gray-50 transition-colors">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-4">
                          <div className="flex items-center justify-center w-10 h-10 rounded-full bg-blue-100 text-blue-600 font-bold">
                            #{sortedMatches.length - index}
                          </div>
                          <div>
                            <div className="flex items-center space-x-2 mb-1">
                              <span className={`font-semibold ${isPlayer1Winner ? "text-green-600" : "text-gray-700"}`}>
                                {player1Name}
                              </span>
                              <span className="text-gray-400">vs</span>
                              <span
                                className={`font-semibold ${!isPlayer1Winner ? "text-green-600" : "text-gray-700"}`}
                              >
                                {player2Name}
                              </span>
                            </div>
                            <div className="flex items-center space-x-2 text-sm text-gray-500">
                              <Calendar className="h-4 w-4" />
                              <span>
                                {new Date(match.date).toLocaleDateString("es-ES", {
                                  year: "numeric",
                                  month: "long",
                                  day: "numeric",
                                })}
                              </span>
                            </div>
                          </div>
                        </div>

                        <div className="flex items-center space-x-6">
                          <div className="text-center">
                            <div className="text-2xl font-bold text-gray-900">
                              {match.player1Sets} - {match.player2Sets}
                            </div>
                            <div className="text-sm text-gray-500">Sets</div>
                          </div>

                          <div className="text-center">
                            <div className="text-lg font-medium text-gray-700">
                              {match.player1Games} - {match.player2Games}
                            </div>
                            <div className="text-sm text-gray-500">Games</div>
                          </div>

                          <div className="text-center">
                            <Badge variant="default" className="bg-green-600">
                              <Trophy className="h-3 w-3 mr-1" />
                              {winnerName}
                            </Badge>
                            <div className="text-sm text-gray-500 mt-1">Ganador</div>
                          </div>

                          {match.isSuperTiebreak && (
                            <div className="text-center">
                              <Badge variant="outline">Super Tiebreak</Badge>
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </CardContent>
        </Card>

        {sortedMatches.length > 0 && (
          <div className="text-center mt-6">
            <div className="flex items-center justify-center space-x-6 text-gray-600">
              <div className="flex items-center">
                <Users className="h-4 w-4 mr-1" />
                <span>{players.length} jugadores activos</span>
              </div>
              <div className="flex items-center">
                <Calendar className="h-4 w-4 mr-1" />
                <span>{matches.length} partidos disputados</span>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
