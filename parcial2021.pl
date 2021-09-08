% Punto 1 - Modelado
noticia(artVandalay,articulo("Nuevo título para Lloyd Braun",deportista(lloydBraun,5)),25).
noticia(elaineBenes,articulo("Primicia",farandula(seinfeld,kennyBania)),16).
noticia(elaineBenes,articulo("El dolar bajó",farandula(seinfeld,newman)),150).
noticia(bobSacamano,articulo("No consigue ganar una carrera",deportista(davidPuddy,0)),10).
noticia(bobSacamano,articulo("Cosmo Kramer encabeza las elecciones!",politico(cosmoKramer,amigosDelPoder)),155).

noticia(costanza,Articulo,Visitas):- noticia(bobSacamano,Articulo,Visitas).
noticia(costanza,articulo(Titulo,politico(Famoso,amigosDelPoder)),Visitas):-
   noticia(_,articulo(Titulo,farandula(Famoso,_)),VisitasOriginales), Visitas is VisitasOriginales / 2.

% Elaine Benes no roba las noticias de artVandalay. -> Universo Cerrado, todo lo que no se conoce
% o se sabe falso no se registra en la base de conocimientos.

% Punto 2
% un articulo es amarillista si el título es "Primicia" o la persona involucrada en la noticia está complicada
% Por ejemplo, el artículo de Elaine Benes que dice "Primicia" es amarillista, o bien... etc.

esAmarillista(articulo("Primicia",_)).
esAmarillista(articulo(_,Persona)):-estaComplicado(Persona).

estaComplicado(politico(_,_)).
estaComplicado(deportista(_,Titulos)):-Titulos < 3.
estaComplicado(farandula(_,seinfeld)).

% Punto 3
autor(Autor):- distinct(Autor, noticia(Autor,_,_)).

% A un autor no le importa nada si todas sus noticias muy visitadas son amarillistas. Las noticias muy visitadas son las que tienen más de 15 visitas.
noLeImportaNada(Autor):-autor(Autor), forall(noticiaMuyVisitada(Autor,Articulo), esAmarillista(Articulo)).
noticiaMuyVisitada(Autor,Articulo):-noticia(Autor,Articulo,Visitas),Visitas > 15.

% Un autor es muy original si no hay otra noticia que tenga el mismo título.
esMuyOriginal(Autor):- autor(Autor), not((noticia(OtroAutor,articulo(Titulo,_),_),noticia(Autor,articulo(Titulo,_),_),Autor \= OtroAutor)).

% un autor tuvo un traspié si tiene al menos una noticia poco visitada.
tuvoUnTraspie(Autor):- noticia(Autor, Articulo, _), not(noticiaMuyVisitada(Autor, Articulo)).

% Punto 4
% Edición loca: queremos armar un resumen de la semana con una combinación posible de artículos amarillistas
% que no superen 50 visitas en total.
edicionLoca(Articulos):-
  findall(noticiaVisitada(Articulo,Visitas),(noticia(_,Articulo,Visitas),esAmarillista(Articulo)),Noticias),
  articulosPosibles(Noticias,0,Articulos).

articulosPosibles([],_,[]).
articulosPosibles([noticiaVisitada(Articulo,Visitas)|Noticias],Cantidad,[Articulo|Posibles]):-
  ProximaCantidad is Cantidad + Visitas,
  ProximaCantidad < 50,
  articulosPosibles(Noticias,ProximaCantidad, Posibles).
articulosPosibles([_|Noticias],Cantidad,Posibles):-
  articulosPosibles(Noticias,Cantidad,Posibles).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- begin_tests(noticias).

test(un_articulo_con_titulo_primicia_esAmarillista, nondet) :-
  esAmarillista(articulo("Primicia",farandula(seinfeld,kennyBania))).

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

test(no_le_importa_nada, set(Autor == [bobSacamano, costanza])):-
  noLeImportaNada(Autor).

test(es_muy_original, set(Autor == [artVandalay])):-
  esMuyOriginal(Autor).

test(tuvo_un_traspie, set(Autor == [bobSacamano, costanza])):-
  tuvoUnTraspie(Autor).

:- end_tests(noticias).
