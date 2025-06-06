"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Calendar, Clock, MapPin } from "lucide-react"
import { useTournament } from "@/contexts/tournament-context"
import Navigation from "@/components/navigation"

export default function UpcomingMatchesPage() {
  const { players, upcomingMatches } = useTournament()

  const getPlayerName = (playerId: string) => {
    return players.find((p) => p.id === playerId)?.name || "Jugador desconocido"
  }

  // Ordenar por fecha y hora
  const sortedMatches = [...upcomingMatches].sort((a, b) => {
    const dateA = new Date(`${a.scheduledDate}T${a.scheduledTime}`)
    const dateB = new Date(`${b.scheduledDate}T${b.scheduledTime}`)
    return dateA.getTime() - dateB.getTime()
  })

  // Agrupar por fecha
  const matchesByDate = sortedMatches.reduce(
    (acc, match) => {
      const date = match.scheduledDate
      if (!acc[date]) {
        acc[date] = []
      }
      acc[date].push(match)
      return acc
    },
    {} as Record<string, typeof upcomingMatches>,
  )

  // Ordenar las fechas
  const sortedDates = Object.keys(matchesByDate).sort((a, b) => {
    return new Date(a).getTime() - new Date(b).getTime()
  })

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("es-ES", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  const isToday = (dateString: string) => {
    const today = new Date()
    const date = new Date(dateString)
    return (
      date.getDate() === today.getDate() &&
      date.getMonth() === today.getMonth() &&
      date.getFullYear() === today.getFullYear()
    )
  }

  const isTomorrow = (dateString: string) => {
    const tomorrow = new Date()
    tomorrow.setDate(tomorrow.getDate() + 1)
    const date = new Date(dateString)
    return (
      date.getDate() === tomorrow.getDate() &&
      date.getMonth() === tomorrow.getMonth() &&
      date.getFullYear() === tomorrow.getFullYear()
    )
  }

  const getDateLabel = (dateString: string) => {
    if (isToday(dateString)) return "Hoy"
    if (isTomorrow(dateString)) return "Mañana"
    return formatDate(dateString)
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <Navigation />

      <div className="container mx-auto px-4 py-8">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Próximos Partidos</h1>
          <p className="text-lg text-gray-600">Calendario de encuentros programados</p>
        </div>

        {sortedMatches.length === 0 ? (
          <Card className="max-w-4xl mx-auto shadow-lg">
            <CardContent className="p-12 text-center">
              <Calendar className="h-16 w-16 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-500 text-lg">No hay partidos programados</p>
              <p className="text-gray-400">Los próximos partidos aparecerán aquí cuando sean programados</p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-8 max-w-4xl mx-auto">
            {sortedDates.map((date) => (
              <Card key={date} className="shadow-lg">
                <CardHeader className="bg-gradient-to-r from-blue-600 to-green-600 text-white">
                  <CardTitle className="text-xl flex items-center gap-2">
                    <Calendar className="h-5 w-5" />
                    {getDateLabel(date)}
                    {isToday(date) && (
                      <Badge variant="secondary" className="bg-yellow-500 text-white">
                        HOY
                      </Badge>
                    )}
                    {isTomorrow(date) && (
                      <Badge variant="secondary" className="bg-orange-500 text-white">
                        MAÑANA
                      </Badge>
                    )}
                  </CardTitle>
                </CardHeader>
                <CardContent className="p-0">
                  <div className="divide-y divide-gray-200">
                    {matchesByDate[date].map((match) => {
                      const player1Name = getPlayerName(match.player1Id)
                      const player2Name = getPlayerName(match.player2Id)
                      const matchTime = new Date(`${match.scheduledDate}T${match.scheduledTime}`)

                      return (
                        <div key={match.id} className="p-6 hover:bg-gray-50 transition-colors">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center space-x-4">
                              <div className="flex items-center justify-center w-12 h-12 rounded-full bg-blue-100">
                                <Clock className="h-6 w-6 text-blue-600" />
                              </div>
                              <div>
                                <div className="flex items-center space-x-2 mb-1">
                                  <span className="font-semibold text-lg text-gray-900">{player1Name}</span>
                                  <span className="text-gray-400 font-medium">vs</span>
                                  <span className="font-semibold text-lg text-gray-900">{player2Name}</span>
                                </div>
                                <div className="flex items-center space-x-4 text-sm text-gray-600">
                                  <div className="flex items-center">
                                    <Clock className="h-4 w-4 mr-1" />
                                    <span>
                                      {matchTime.toLocaleTimeString("es-ES", {
                                        hour: "2-digit",
                                        minute: "2-digit",
                                      })}
                                    </span>
                                  </div>
                                  {match.location && (
                                    <div className="flex items-center">
                                      <MapPin className="h-4 w-4 mr-1" />
                                      <span>{match.location}</span>
                                    </div>
                                  )}
                                </div>
                              </div>
                            </div>

                            <div className="text-right">
                              <Badge variant="outline" className="text-blue-600 border-blue-600">
                                Programado
                              </Badge>
                              {isToday(date) && <div className="text-sm text-orange-600 font-medium mt-1">¡Hoy!</div>}
                            </div>
                          </div>
                        </div>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
