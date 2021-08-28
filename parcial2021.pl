% Punto 1 - Modelado

% noticia(autor,articulo(titulo,personaInvolucrada),cantidadDeVisitas)

% politico(persona,partido)

% deportista(persona,titulosGanados)

% farandula(persona,conQuienTieneProblema)
noticia(elaineBenes,articulo("Nuevo título para Lloyd Braun",deportista(lloydBraun,5)),25).
noticia(elaineBenes,articulo("primicia",farandula(seinfeld,kennyBania)),16).
noticia(artVandalay,articulo("El dolar bajó",farandula(seinfeld,newman)),150).
noticia(bobSacamano,articulo("No consigue ganar una carrera",deportista(davidPuddy,0)),10).
noticia(bobSacamano,articulo("Cosmo Kramer encabeza las elecciones!",politico(cosmoKramer,amigosDelPoder)),155).

%George Costanza roba las noticias de Bob Sacamano obteniendo la misma cantidad de visitas y todas las noticias de farándula las 
%transforma en noticias de política involucrando al famoso como político perteneciente al partido amigos del poder, pero como la
%noticia es puro chamullo obtiene la mitad de las visitas que la original.
noticia(constanza,Articulo,Visitas):- noticia(bobSacamano,Articulo,Visitas).
noticia(constanza,Titulo,politico(Famoso,amigosDelPoder),Visitas):- noticia(_,articulo(Titulo,farandula(Famoso,_)),VisitasOriginales), Visitas is VisitasOriginales / 2.

% Elaine Benes no roba las noticias de artVandalay. -> Universo Cerrado

% Punto 2
% un articulo es amarillista si el título es "Primicia" o alguna de las personas involucradas en la noticia está complicada

esAmarillista(articulo("primicia",_)).
esAmarillista(articulo(_,Persona)):-estaComplicado(Persona).

estaComplicado(politico(_,_)).
estaComplicado(deportista(_,Titulos)):-Titulos < 3.
estaComplicado(farandula(_,seinfeld)).


% Punto 3
autor(Autor):- noticia(Autor,_,_).

% A un autor no le importa nada si todas sus noticias muy visitadas son amarillistas. Las noticias muy visitadas son las que tienen más de 15 visitas.
noLeImportaNada(Autor):-distinct(autor(Autor)), forall(noticiaMuyVisitada(noticia(Autor,Articulo,_)),esAmarillista(Articulo)).

noticiaMuyVisitada(noticia(Autor,Articulo,Visitas)):-noticia(Autor,Articulo,Visitas),Visitas > 15.

% Un autor es muy original si no existe alguna noticia de otro autor que tenga alguno de los nombres de sus publicaciones.  
esMuyOriginal(Autor):- distinct(autor(Autor)), not((noticia(OtroAutor,articulo(Titulo,_),_),noticia(Autor,articulo(Titulo,_),_),Autor \= OtroAutor)).

% Punto 4
% un autor tuvo un traspié si tiene al menos una noticia poco visitada.
% Acá apunto al mal uso del findall, cosa que suele suceder. Queda muy corto, por ahí se puede sumar al 3 y dejar solo 4 puntos. 
tuvoUnTraspie(Autor):- noticia(Autor,_,Visitas), not(noticiaMuyVisitada(noticia(Autor,_,Visitas))).

% Punto 5
% Edición loca: queremos armar una edición de artículos amarillistas que puedan conformar el resumen de la semana
% que tiene que estar compuesto por noticias amarillistas que no superen 40 visitas en total.

edicionLoca(Articulos):-
  findall(noticia(_,Articulo,Visitas),(noticia(_,Articulo,Visitas),esAmarillista(Articulo)),Noticias),
  articulosPosibles(Noticias,0,Articulos).

articulosPosibles([],_,[]).
articulosPosibles([noticia(_,Articulo,Visitas)|Noticias],Cantidad,[Articulo|Posibles]):-
  ProximaCantidad is Cantidad + Visitas,
  ProximaCantidad < 40,
  articulosPosibles(Noticias,ProximaCantidad, Posibles).
articulosPosibles([_|Noticias],Cantidad,Posibles):-
  articulosPosibles(Noticias,Cantidad,Posibles).

:- begin_tests(noticias).

test(un_articulo_con_titulo_primicia_esAmarillista, nondet) :-
  esAmarillista(articulo("primicia",farandula(seinfeld,kennyBania))).

test(un_politico_esta_complicado):-
  estaComplicado(politico(cosmoKramer,partidoLoco)).

test(un_deportista_sin_titulos_esta_complicado):- 
  estaComplicado(deportista(pepe,0)).

test(un_deportista_con_titulos_no_esta_complicado, fail):-
  estaComplicado(deportista(pepe,10)).

test(un_farandulero_que_tiene_problemas_con_seinfeld_esta_complicado):-
  estaComplicado(farandula(newman,seinfeld)).

test(un_farandulero_que_no_tiene_problemas_con_seinfeld_no_esta_complicado, fail):-
  estaComplicado(farandula(newman,kramer)).

test(no_le_importa_nada, set(Autor == [bobSacamano, constanza])):-
  noLeImportaNada(Autor).

test(no_le_importa_nada, set(Autor == [elaineBenes, artVandalay])):-
  esMuyOriginal(Autor).

test(tuvo_un_traspie, set(Autor == [bobSacamano, constanza])):-
  tuvoUnTraspie(Autor).

:- end_tests(noticias).
