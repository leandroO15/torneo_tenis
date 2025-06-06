"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Trash2, Plus, Users, Calendar, Shield, Clock, Edit } from "lucide-react"
import { useTournament } from "@/contexts/tournament-context"
import Navigation from "@/components/navigation"
import { useRouter } from "next/navigation"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"

export default function AdminPage() {
  const router = useRouter()
  const {
    players,
    matches,
    upcomingMatches,
    addPlayer,
    addMatch,
    removePlayer,
    removeMatch,
    addUpcomingMatch,
    removeUpcomingMatch,
    updateMatch,
  } = useTournament()
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const [loginForm, setLoginForm] = useState({ username: "", password: "" })
  const [playerForm, setPlayerForm] = useState({ name: "" })
  const [matchForm, setMatchForm] = useState({
    player1Id: "",
    player2Id: "",
    set1Player1Games: 0,
    set1Player2Games: 0,
    set2Player1Games: 0,
    set2Player2Games: 0,
    set3Player1Games: 0,
    set3Player2Games: 0,
  })
  const [upcomingMatchForm, setUpcomingMatchForm] = useState({
    player1Id: "",
    player2Id: "",
    scheduledDate: "",
    scheduledTime: "",
  })
  const [editingMatch, setEditingMatch] = useState<null | {
    id: string
    player1Id: string
    player2Id: string
    set1Player1Games: number
    set1Player2Games: number
    set2Player1Games: number
    set2Player2Games: number
    set3Player1Games: number
    set3Player2Games: number
  }>(null)

  useEffect(() => {
    const authStatus = localStorage.getItem("adminAuth")
    if (authStatus === "true") {
      setIsAuthenticated(true)
    }
  }, [])

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault()
    if (loginForm.username === "carlos" && loginForm.password === "carlos123") {
      setIsAuthenticated(true)
      localStorage.setItem("adminAuth", "true")
    } else {
      alert("Credenciales incorrectas")
    }
  }

  const handleLogout = () => {
    setIsAuthenticated(false)
    localStorage.removeItem("adminAuth")
    router.push("/")
  }

  const handleAddPlayer = (e: React.FormEvent) => {
    e.preventDefault()
    if (playerForm.name) {
      addPlayer(playerForm.name)
      setPlayerForm({ name: "" })
    }
  }

  // Función para calcular quién ganó cada set
  const getSetWinner = (player1Games: number, player2Games: number) => {
    return player1Games > player2Games ? 1 : 2
  }

  // Función para validar y procesar el formulario de partido
  const processMatchForm = (form: typeof matchForm) => {
    // Verificar que se hayan seleccionado jugadores diferentes
    if (!form.player1Id || !form.player2Id || form.player1Id === form.player2Id) {
      alert("Debes seleccionar dos jugadores diferentes")
      return null
    }

    // Verificar que se hayan completado los dos primeros sets
    if (
      form.set1Player1Games === 0 &&
      form.set1Player2Games === 0 &&
      form.set2Player1Games === 0 &&
      form.set2Player2Games === 0
    ) {
      alert("Debes completar los resultados de al menos los dos primeros sets")
      return null
    }

    // Calcular ganadores de cada set
    const set1Winner = getSetWinner(form.set1Player1Games, form.set1Player2Games)
    const set2Winner = getSetWinner(form.set2Player1Games, form.set2Player2Games)

    let player1Sets = 0
    let player2Sets = 0
    let isSuperTiebreak = false
    let winnerId = ""

    // Contar sets ganados en los primeros 2 sets
    if (set1Winner === 1) player1Sets++
    else player2Sets++

    if (set2Winner === 1) player1Sets++
    else player2Sets++

    // Si hay empate 1-1, verificar el tercer set
    if (player1Sets === 1 && player2Sets === 1) {
      if (form.set3Player1Games === 0 && form.set3Player2Games === 0) {
        alert("Hay empate 1-1 en sets. Debes completar el resultado del Super Tiebreak (Set 3)")
        return null
      }

      if (form.set3Player1Games === form.set3Player2Games) {
        alert("En el Super Tiebreak debe haber un ganador. Los games no pueden estar empatados.")
        return null
      }

      isSuperTiebreak = true
      const set3Winner = getSetWinner(form.set3Player1Games, form.set3Player2Games)
      if (set3Winner === 1) {
        player1Sets++
        winnerId = form.player1Id
      } else {
        player2Sets++
        winnerId = form.player2Id
      }
    } else {
      // Sin empate, el ganador se determina por los primeros 2 sets
      winnerId = player1Sets > player2Sets ? form.player1Id : form.player2Id
    }

    // Calcular games totales según las reglas especificadas
    let player1Games = form.set1Player1Games + form.set2Player1Games
    let player2Games = form.set1Player2Games + form.set2Player2Games

    // En el tercer set (super tiebreak), solo se suma 1 game al ganador
    if (isSuperTiebreak) {
      if (winnerId === form.player1Id) {
        player1Games += 1
      } else {
        player2Games += 1
      }
    }

    return {
      player1Id: form.player1Id,
      player2Id: form.player2Id,
      set1Player1Games: form.set1Player1Games,
      set1Player2Games: form.set1Player2Games,
      set2Player1Games: form.set2Player1Games,
      set2Player2Games: form.set2Player2Games,
      set3Player1Games: form.set3Player1Games,
      set3Player2Games: form.set3Player2Games,
      player1Sets,
      player2Sets,
      player1Games,
      player2Games,
      isSuperTiebreak,
      winnerId,
    }
  }

  const handleAddMatch = (e: React.FormEvent) => {
    e.preventDefault()

    const processedMatch = processMatchForm(matchForm)
    if (processedMatch) {
      addMatch(processedMatch)
      setMatchForm({
        player1Id: "",
        player2Id: "",
        set1Player1Games: 0,
        set1Player2Games: 0,
        set2Player1Games: 0,
        set2Player2Games: 0,
        set3Player1Games: 0,
        set3Player2Games: 0,
      })
    }
  }

  const handleUpdateMatch = (e: React.FormEvent) => {
    e.preventDefault()

    if (!editingMatch) return

    const processedMatch = processMatchForm(editingMatch)
    if (processedMatch) {
      updateMatch(editingMatch.id, processedMatch)
      setEditingMatch(null)
    }
  }

  const handleAddUpcomingMatch = (e: React.FormEvent) => {
    e.preventDefault()
    if (
      upcomingMatchForm.player1Id &&
      upcomingMatchForm.player2Id &&
      upcomingMatchForm.scheduledDate &&
      upcomingMatchForm.scheduledTime &&
      upcomingMatchForm.player1Id !== upcomingMatchForm.player2Id
    ) {
      addUpcomingMatch({
        player1Id: upcomingMatchForm.player1Id,
        player2Id: upcomingMatchForm.player2Id,
        scheduledDate: upcomingMatchForm.scheduledDate,
        scheduledTime: upcomingMatchForm.scheduledTime,
      })

      setUpcomingMatchForm({
        player1Id: "",
        player2Id: "",
        scheduledDate: "",
        scheduledTime: "",
      })
    }
  }

  const startEditMatch = (match: (typeof matches)[0]) => {
    setEditingMatch({
      id: match.id,
      player1Id: match.player1Id,
      player2Id: match.player2Id,
      set1Player1Games: match.set1Player1Games,
      set1Player2Games: match.set1Player2Games,
      set2Player1Games: match.set2Player1Games,
      set2Player2Games: match.set2Player2Games,
      set3Player1Games: match.set3Player1Games,
      set3Player2Games: match.set3Player2Games,
    })
  }

  // Verificar si necesita el tercer set
  const needsThirdSet = (form: typeof matchForm) => {
    const set1Winner = getSetWinner(form.set1Player1Games, form.set1Player2Games)
    const set2Winner = getSetWinner(form.set2Player1Games, form.set2Player2Games)
    return set1Winner !== set2Winner && form.set1Player1Games > 0 && form.set2Player1Games > 0
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 flex items-center justify-center">
        <Card className="w-full max-w-md shadow-lg">
          <CardHeader className="text-center">
            <Shield className="h-12 w-12 text-blue-600 mx-auto mb-2" />
            <CardTitle className="text-2xl">Acceso Administrativo</CardTitle>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <Label htmlFor="username">Usuario</Label>
                <Input
                  id="username"
                  type="text"
                  value={loginForm.username}
                  onChange={(e) => setLoginForm({ ...loginForm, username: e.target.value })}
                  required
                />
              </div>
              <div>
                <Label htmlFor="password">Contraseña</Label>
                <Input
                  id="password"
                  type="password"
                  value={loginForm.password}
                  onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                  required
                />
              </div>
              <Button type="submit" className="w-full">
                Iniciar Sesión
              </Button>
            </form>
          </CardContent>
        </Card>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50">
      <Navigation />

      <div className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-8">
          <div>
            <h1 className="text-4xl font-bold text-gray-900 mb-2">Panel de Administración</h1>
            <p className="text-lg text-gray-600">Gestión del torneo</p>
          </div>
          <Button onClick={handleLogout} variant="outline">
            Cerrar Sesión
          </Button>
        </div>

        <Tabs defaultValue="players" className="space-y-6">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="players" className="flex items-center gap-2">
              <Users className="h-4 w-4" />
              Jugadores
            </TabsTrigger>
            <TabsTrigger value="matches" className="flex items-center gap-2">
              <Calendar className="h-4 w-4" />
              Partidos
            </TabsTrigger>
            <TabsTrigger value="upcoming" className="flex items-center gap-2">
              <Clock className="h-4 w-4" />
              Próximos Partidos
            </TabsTrigger>
          </TabsList>

          <TabsContent value="players">
            <div className="grid gap-6 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Plus className="h-5 w-5" />
                    Agregar Jugador
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleAddPlayer} className="space-y-4">
                    <div>
                      <Label htmlFor="playerName">Nombre del Jugador</Label>
                      <Input
                        id="playerName"
                        value={playerForm.name}
                        onChange={(e) => setPlayerForm({ ...playerForm, name: e.target.value })}
                        placeholder="Ej: Juan Pérez"
                        required
                      />
                    </div>
                    <Button type="submit" className="w-full">
                      Agregar Jugador
                    </Button>
                  </form>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Jugadores Registrados ({players.length})</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3 max-h-96 overflow-y-auto">
                    {players.map((player) => (
                      <div key={player.id} className="flex items-center justify-between p-3 border rounded-lg">
                        <div>
                          <p className="font-medium">{player.name}</p>
                        </div>
                        <Button onClick={() => removePlayer(player.id)} variant="destructive" size="sm">
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    ))}
                    {players.length === 0 && (
                      <p className="text-gray-500 text-center py-4">No hay jugadores registrados</p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="matches">
            <div className="grid gap-6 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Plus className="h-5 w-5" />
                    Registrar Partido
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleAddMatch} className="space-y-4">
                    <div>
                      <Label>Jugador 1</Label>
                      <Select
                        value={matchForm.player1Id}
                        onValueChange={(value) => setMatchForm({ ...matchForm, player1Id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Seleccionar jugador 1" />
                        </SelectTrigger>
                        <SelectContent>
                          {players.map((player) => (
                            <SelectItem key={player.id} value={player.id}>
                              {player.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <Label>Jugador 2</Label>
                      <Select
                        value={matchForm.player2Id}
                        onValueChange={(value) => setMatchForm({ ...matchForm, player2Id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Seleccionar jugador 2" />
                        </SelectTrigger>
                        <SelectContent>
                          {players
                            .filter((p) => p.id !== matchForm.player1Id)
                            .map((player) => (
                              <SelectItem key={player.id} value={player.id}>
                                {player.name}
                              </SelectItem>
                            ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* Set 1 */}
                    <div className="border rounded-lg p-4 bg-blue-50">
                      <h4 className="font-medium text-blue-800 mb-3">Set 1</h4>
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <Label>Games Jugador 1</Label>
                          <Input
                            type="number"
                            min="0"
                            value={matchForm.set1Player1Games}
                            onChange={(e) =>
                              setMatchForm({ ...matchForm, set1Player1Games: Number.parseInt(e.target.value) || 0 })
                            }
                            required
                          />
                        </div>
                        <div>
                          <Label>Games Jugador 2</Label>
                          <Input
                            type="number"
                            min="0"
                            value={matchForm.set1Player2Games}
                            onChange={(e) =>
                              setMatchForm({ ...matchForm, set1Player2Games: Number.parseInt(e.target.value) || 0 })
                            }
                            required
                          />
                        </div>
                      </div>
                    </div>

                    {/* Set 2 */}
                    <div className="border rounded-lg p-4 bg-green-50">
                      <h4 className="font-medium text-green-800 mb-3">Set 2</h4>
                      <div className="grid grid-cols-2 gap-4">
                        <div>
                          <Label>Games Jugador 1</Label>
                          <Input
                            type="number"
                            min="0"
                            value={matchForm.set2Player1Games}
                            onChange={(e) =>
                              setMatchForm({ ...matchForm, set2Player1Games: Number.parseInt(e.target.value) || 0 })
                            }
                            required
                          />
                        </div>
                        <div>
                          <Label>Games Jugador 2</Label>
                          <Input
                            type="number"
                            min="0"
                            value={matchForm.set2Player2Games}
                            onChange={(e) =>
                              setMatchForm({ ...matchForm, set2Player2Games: Number.parseInt(e.target.value) || 0 })
                            }
                            required
                          />
                        </div>
                      </div>
                    </div>

                    {/* Set 3 - Solo si hay empate */}
                    {needsThirdSet(matchForm) && (
                      <div className="border rounded-lg p-4 bg-yellow-50">
                        <div className="flex items-center gap-2 mb-3">
                          <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                          <h4 className="font-medium text-yellow-800">Set 3 - Super Tiebreak</h4>
                        </div>
                        <p className="text-yellow-700 text-sm mb-3">
                          Hay empate 1-1 en sets. Completa el resultado del Super Tiebreak.
                        </p>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <Label>Games Jugador 1</Label>
                            <Input
                              type="number"
                              min="0"
                              value={matchForm.set3Player1Games}
                              onChange={(e) =>
                                setMatchForm({ ...matchForm, set3Player1Games: Number.parseInt(e.target.value) || 0 })
                              }
                              required
                            />
                          </div>
                          <div>
                            <Label>Games Jugador 2</Label>
                            <Input
                              type="number"
                              min="0"
                              value={matchForm.set3Player2Games}
                              onChange={(e) =>
                                setMatchForm({ ...matchForm, set3Player2Games: Number.parseInt(e.target.value) || 0 })
                              }
                              required
                            />
                          </div>
                        </div>
                      </div>
                    )}

                    <Button type="submit" className="w-full" disabled={players.length < 2}>
                      Registrar Partido
                    </Button>
                  </form>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Partidos Registrados ({matches.length})</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3 max-h-96 overflow-y-auto">
                    {matches.map((match) => {
                      const player1 = players.find((p) => p.id === match.player1Id)
                      const player2 = players.find((p) => p.id === match.player2Id)
                      const winner = players.find((p) => p.id === match.winnerId)

                      return (
                        <div key={match.id} className="p-3 border rounded-lg">
                          <div className="flex items-center justify-between">
                            <div className="flex-1">
                              <p className="font-medium">
                                {player1?.name} vs {player2?.name}
                              </p>
                              <div className="flex items-center gap-4 mt-1">
                                <p className="text-sm text-gray-600">
                                  Sets: {match.player1Sets} - {match.player2Sets}
                                </p>
                                <p className="text-sm text-gray-600">
                                  Games: {match.player1Games} - {match.player2Games}
                                </p>
                              </div>
                              <div className="text-xs text-gray-500 mt-1">
                                {match.set1Player1Games}-{match.set1Player2Games}, {match.set2Player1Games}-
                                {match.set2Player2Games}
                                {match.isSuperTiebreak && (
                                  <span>
                                    , {match.set3Player1Games}-{match.set3Player2Games}
                                  </span>
                                )}
                              </div>
                              <div className="flex items-center gap-2 mt-1">
                                <Badge variant="outline" className="mt-1">
                                  Ganador: {winner?.name}
                                </Badge>
                                {match.isSuperTiebreak && (
                                  <Badge variant="secondary" className="mt-1">
                                    Super Tiebreak
                                  </Badge>
                                )}
                              </div>
                            </div>
                            <div className="flex gap-2">
                              <Button onClick={() => startEditMatch(match)} variant="outline" size="sm">
                                <Edit className="h-4 w-4" />
                              </Button>
                              <Button onClick={() => removeMatch(match.id)} variant="destructive" size="sm">
                                <Trash2 className="h-4 w-4" />
                              </Button>
                            </div>
                          </div>
                        </div>
                      )
                    })}
                    {matches.length === 0 && (
                      <p className="text-gray-500 text-center py-4">No hay partidos registrados</p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          <TabsContent value="upcoming">
            <div className="grid gap-6 md:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Plus className="h-5 w-5" />
                    Programar Partido
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <form onSubmit={handleAddUpcomingMatch} className="space-y-4">
                    <div>
                      <Label>Jugador 1</Label>
                      <Select
                        value={upcomingMatchForm.player1Id}
                        onValueChange={(value) => setUpcomingMatchForm({ ...upcomingMatchForm, player1Id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Seleccionar jugador 1" />
                        </SelectTrigger>
                        <SelectContent>
                          {players.map((player) => (
                            <SelectItem key={player.id} value={player.id}>
                              {player.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <Label>Jugador 2</Label>
                      <Select
                        value={upcomingMatchForm.player2Id}
                        onValueChange={(value) => setUpcomingMatchForm({ ...upcomingMatchForm, player2Id: value })}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Seleccionar jugador 2" />
                        </SelectTrigger>
                        <SelectContent>
                          {players
                            .filter((p) => p.id !== upcomingMatchForm.player1Id)
                            .map((player) => (
                              <SelectItem key={player.id} value={player.id}>
                                {player.name}
                              </SelectItem>
                            ))}
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="scheduledDate">Fecha</Label>
                        <Input
                          id="scheduledDate"
                          type="date"
                          value={upcomingMatchForm.scheduledDate}
                          onChange={(e) =>
                            setUpcomingMatchForm({ ...upcomingMatchForm, scheduledDate: e.target.value })
                          }
                          required
                        />
                      </div>
                      <div>
                        <Label htmlFor="scheduledTime">Hora</Label>
                        <Input
                          id="scheduledTime"
                          type="time"
                          value={upcomingMatchForm.scheduledTime}
                          onChange={(e) =>
                            setUpcomingMatchForm({ ...upcomingMatchForm, scheduledTime: e.target.value })
                          }
                          required
                        />
                      </div>
                    </div>
                    <Button type="submit" className="w-full" disabled={players.length < 2}>
                      Programar Partido
                    </Button>
                  </form>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Partidos Programados ({upcomingMatches.length})</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3 max-h-96 overflow-y-auto">
                    {upcomingMatches.map((match) => {
                      const player1 = players.find((p) => p.id === match.player1Id)
                      const player2 = players.find((p) => p.id === match.player2Id)
                      const matchDate = new Date(`${match.scheduledDate}T${match.scheduledTime}`)

                      return (
                        <div key={match.id} className="p-3 border rounded-lg">
                          <div className="flex items-center justify-between">
                            <div className="flex-1">
                              <p className="font-medium">
                                {player1?.name} vs {player2?.name}
                              </p>
                              <div className="flex items-center gap-2 mt-1">
                                <Calendar className="h-4 w-4 text-gray-500" />
                                <p className="text-sm text-gray-600">
                                  {matchDate.toLocaleDateString("es-ES", {
                                    weekday: "long",
                                    year: "numeric",
                                    month: "long",
                                    day: "numeric",
                                  })}
                                </p>
                              </div>
                              <div className="flex items-center gap-2 mt-1">
                                <Clock className="h-4 w-4 text-gray-500" />
                                <p className="text-sm text-gray-600">
                                  {matchDate.toLocaleTimeString("es-ES", {
                                    hour: "2-digit",
                                    minute: "2-digit",
                                  })}
                                </p>
                              </div>
                            </div>
                            <Button onClick={() => removeUpcomingMatch(match.id)} variant="destructive" size="sm">
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      )
                    })}
                    {upcomingMatches.length === 0 && (
                      <p className="text-gray-500 text-center py-4">No hay partidos programados</p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>

      {/* Modal de edición de partido */}
      {editingMatch && (
        <Dialog open={!!editingMatch} onOpenChange={(open) => !open && setEditingMatch(null)}>
          <DialogContent className="sm:max-w-lg">
            <DialogHeader>
              <DialogTitle>Editar Partido</DialogTitle>
            </DialogHeader>
            <form onSubmit={handleUpdateMatch} className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <Label>Jugador 1</Label>
                  <p className="font-medium text-gray-700">
                    {players.find((p) => p.id === editingMatch.player1Id)?.name}
                  </p>
                </div>
                <div>
                  <Label>Jugador 2</Label>
                  <p className="font-medium text-gray-700">
                    {players.find((p) => p.id === editingMatch.player2Id)?.name}
                  </p>
                </div>
              </div>

              {/* Set 1 */}
              <div className="border rounded-lg p-4 bg-blue-50">
                <h4 className="font-medium text-blue-800 mb-3">Set 1</h4>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Games Jugador 1</Label>
                    <Input
                      type="number"
                      min="0"
                      value={editingMatch.set1Player1Games}
                      onChange={(e) =>
                        setEditingMatch({
                          ...editingMatch,
                          set1Player1Games: Number.parseInt(e.target.value) || 0,
                        })
                      }
                      required
                    />
                  </div>
                  <div>
                    <Label>Games Jugador 2</Label>
                    <Input
                      type="number"
                      min="0"
                      value={editingMatch.set1Player2Games}
                      onChange={(e) =>
                        setEditingMatch({
                          ...editingMatch,
                          set1Player2Games: Number.parseInt(e.target.value) || 0,
                        })
                      }
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Set 2 */}
              <div className="border rounded-lg p-4 bg-green-50">
                <h4 className="font-medium text-green-800 mb-3">Set 2</h4>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Games Jugador 1</Label>
                    <Input
                      type="number"
                      min="0"
                      value={editingMatch.set2Player1Games}
                      onChange={(e) =>
                        setEditingMatch({
                          ...editingMatch,
                          set2Player1Games: Number.parseInt(e.target.value) || 0,
                        })
                      }
                      required
                    />
                  </div>
                  <div>
                    <Label>Games Jugador 2</Label>
                    <Input
                      type="number"
                      min="0"
                      value={editingMatch.set2Player2Games}
                      onChange={(e) =>
                        setEditingMatch({
                          ...editingMatch,
                          set2Player2Games: Number.parseInt(e.target.value) || 0,
                        })
                      }
                      required
                    />
                  </div>
                </div>
              </div>

              {/* Set 3 - Solo si hay empate */}
              {needsThirdSet(editingMatch) && (
                <div className="border rounded-lg p-4 bg-yellow-50">
                  <div className="flex items-center gap-2 mb-3">
                    <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
                    <h4 className="font-medium text-yellow-800">Set 3 - Super Tiebreak</h4>
                  </div>
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <Label>Games Jugador 1</Label>
                      <Input
                        type="number"
                        min="0"
                        value={editingMatch.set3Player1Games}
                        onChange={(e) =>
                          setEditingMatch({
                            ...editingMatch,
                            set3Player1Games: Number.parseInt(e.target.value) || 0,
                          })
                        }
                        required
                      />
                    </div>
                    <div>
                      <Label>Games Jugador 2</Label>
                      <Input
                        type="number"
                        min="0"
                        value={editingMatch.set3Player2Games}
                        onChange={(e) =>
                          setEditingMatch({
                            ...editingMatch,
                            set3Player2Games: Number.parseInt(e.target.value) || 0,
                          })
                        }
                        required
                      />
                    </div>
                  </div>
                </div>
              )}

              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setEditingMatch(null)}>
                  Cancelar
                </Button>
                <Button type="submit">Guardar Cambios</Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
