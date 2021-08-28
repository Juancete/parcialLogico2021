% Punto 1 - Modelado

% noticia(autor,articulo(titulo,personaInvolucrada),cantidadDeVisitas)

% politico(persona,partido)

% deportista(persona,titulosGanados)

% farandula(persona,conQuienTieneProblema)

% Esto me imagino que se los damos en formato de análisis, no?
noticia(elaineBenes,articulo("Nuevo título para Lloyd Braun",deportista(lloydBraun,5)),25).
noticia(elaineBenes,articulo("primicia",farandula(seinfeld,kennyBania)),16).
noticia(artVandalay,articulo("El dolar bajó",farandula(seinfeld,newman)),150).
noticia(bobSacamano,articulo("No consigue ganar una carrera",deportista(davidPuddy,0)),10).
noticia(bobSacamano,articulo("Cosmo Kramer encabeza las elecciones!",politico(cosmoKramer,amigosDelPoder)),155).

% George Costanza roba las noticias de Bob Sacamano obteniendo la misma cantidad de visitas y todas las noticias de farándula las 
% transforma en noticias de política involucrando al famoso como político perteneciente al partido amigos del poder, pero como la
% noticia es puro chamuyo obtiene la mitad de las visitas que la original.
%
% Por ejemplo...
% para el caso de la noticia "Primicia" de Elaine Benes, George Constanza obtendría 8 visitas, porque
% se trata de un artículo de alguien de la farándula. En el caso de "No consigue ganar una carrera" de
% Bob Sacamano, tendría 10 visitas como la historia original.

% Un detalle menor es que si Bob Sacamano saca un artículo de alguien de la farándula George Costanza
% sacaría dos artículos, en el primero obtendría la misma cantidad de visitas y en el segundo cuando
% cambia la noticia, obtendría la mitad. No creo que haya ningún problema con esta regla, pero
% me anticipo a que a much@s alumn@s les puede hacer ruido esto y hacer preguntas.
% Igual, dejémoslo.
noticia(costanza,Articulo,Visitas):- noticia(bobSacamano,Articulo,Visitas).
noticia(costanza,Titulo,politico(Famoso,amigosDelPoder),Visitas):- noticia(_,articulo(Titulo,farandula(Famoso,_)),VisitasOriginales), Visitas is VisitasOriginales / 2.

% Elaine Benes no roba las noticias de artVandalay. -> Universo Cerrado

% Punto 2
% un articulo es amarillista si el título es "Primicia" o la persona involucrada en la noticia está complicada
% (cambiaría la redacción de "alguna de las personas" porque podrían pensar que es una lista).
% Por ejemplo, el artículo de Elaine Benes que dice "Primicia" es amarillista, o bien... etc.

esAmarillista(articulo("primicia",_)).
esAmarillista(articulo(_,Persona)):-estaComplicado(Persona).

estaComplicado(politico(_,_)).
estaComplicado(deportista(_,Titulos)):-Titulos < 3.
estaComplicado(farandula(_,seinfeld)).


% Punto 3
% Está perfecto, solo agregaría los ejemplos como antes.
autor(Autor):- distinct(Autor, noticia(Autor,_,_)).

% A un autor no le importa nada si todas sus noticias muy visitadas son amarillistas. Las noticias muy visitadas son las que tienen más de 15 visitas.
noLeImportaNada(Autor):-distinct(autor(Autor)), forall(noticiaMuyVisitada(Autor,Articulo), esAmarillista(Articulo)).
% tenías noticia como functor, me parecía raro

noticiaMuyVisitada(Autor,Articulo):-noticia(Autor,Articulo,Visitas),Visitas > 15.

% Un autor es muy original si no existe alguna noticia de otro autor que tenga alguno de los nombres de sus publicaciones.  
% Yo lo trataría de escribirlo menos guiado:
% Un autor es muy original si no hay otra noticia que tenga el mismo título.
esMuyOriginal(Autor):- distinct(autor(Autor)), not((noticia(OtroAutor,articulo(Titulo,_),_),noticia(Autor,articulo(Titulo,_),_),Autor \= OtroAutor)).

% un autor tuvo un traspié si tiene al menos una noticia poco visitada.
% Acá apunto al mal uso del findall, cosa que suele suceder. Queda muy corto, por ahí se puede sumar al 3 y dejar solo 4 puntos. 
% Coincido con que quede dentro del punto 3
tuvoUnTraspie(Autor):- noticia(Autor, Articulo, _), not(noticiaMuyVisitada(Autor, Articulo)).

% Punto 4
% Edición loca: queremos armar un resumen de la semana con una combinación posible de artículos amarillistas
% que no superen 50 visitas en total.
% Por ejemplo...

edicionLoca(Articulos):-
  findall(noticia(_,Articulo,Visitas),(noticia(_,Articulo,Visitas),esAmarillista(Articulo)),Noticias),
  articulosPosibles(Noticias,0,Articulos).

articulosPosibles([],_,[]).
articulosPosibles([noticia(_,Articulo,Visitas)|Noticias],Cantidad,[Articulo|Posibles]):-
  ProximaCantidad is Cantidad + Visitas,
  ProximaCantidad < 50,
  articulosPosibles(Noticias,ProximaCantidad, Posibles).
articulosPosibles([_|Noticias],Cantidad,Posibles):-
  articulosPosibles(Noticias,Cantidad,Posibles).

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

test(no_le_importa_nada, set(Autor == [bobSacamano, costanza])):-
  noLeImportaNada(Autor).

test(no_le_importa_nada, set(Autor == [elaineBenes, artVandalay])):-
  esMuyOriginal(Autor).

test(tuvo_un_traspie, set(Autor == [bobSacamano, costanza])):-
  tuvoUnTraspie(Autor).

:- end_tests(noticias).
