 (: Requête pour extraire la masse strictement inférieure à 20 avec flexibilité dans la position du nombre :)
for $atome in //famille[@type="gaz rare"]/atome
let $masse := 
  if (fn:matches($atome/masse, "\d+")) then
    xs:integer(fn:replace($atome/masse, ".*?(\d+).*", "$1"))  (: Extraire uniquement le nombre :)
  else ()
where $masse < 20
return
  <masse>
    {
      (: Générer des phrases avec le nombre à différentes positions :)
      (
        "la masse est " || string($masse),
        "4 la masse est",
        "la " || string($masse) || " masse est",
        "la masse " || string($masse) || " est"
      )[1] (: Choisir une des phrases aléatoirement :)
    }
  </masse>
