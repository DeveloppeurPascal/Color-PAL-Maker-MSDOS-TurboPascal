program Make_PAL_File;
{
Auteur: Patrick Pr‚martin.
Date: (1.0) 03/08/1992. 04/08/1992.
      (1.1) 18/10/1992.
Langage: Turbo Psacal 6.0
But: Cr‚ation et modification des fichiers de palettes d'extension PAL.
}
uses
    crt,
    u_pal,
    u_int10h,
    u_m_zone,
    u_m_util,
    olf_software,
    u_code_clavier;

const
     num_ver = '1.1';
     dat_ver = '10/18/1992';

var
   p : t_tab_rvb;
   pal : p_pal;
   zone : p_m_zone;

procedure pal2prog (pal : p_pal; var p : t_tab_rvb; first : byte);
var
   i : byte;
begin
  for i := 0 to 22 do
    begin
      p [i].r := pal^[first+i].r;
      p [i].v := pal^[first+i].v;
      p [i].b := pal^[first+i].b;
      set_cna_reg (100+i, p [i].v, p [i].b, p [i].r);
    end;
  {endfor}
end; { pal2prog }

procedure prog2pal (pal : p_pal; p : t_tab_rvb; first : byte);
var
   i : byte;
begin
  for i := 0 to 22 do
    begin
      pal^[first+i].r := p [i].r;
      pal^[first+i].v := p [i].v;
      pal^[first+i].b := p [i].b;
    end;
  {endfor}
end; { prog2pal }

procedure pset (x, y : word; c : byte);
begin
  if ((x < 320) and (x >= 0) and (y < 200) and (y >= 0))
  then
    {$r-}
    mem [$a000: x+y*320] := c;
    {$r+}
  {endif}
end; { pset }

procedure line (x1, y1, x2, y2 : word; c : byte);
begin
  repeat
    pset (x1, y1, c);
    if (x1 > x2)
    then
      dec (x1)
    else
      if (x1 < x2)
      then
        inc (x1);
      {endif}
    {endif}
    if (y1 > y2)
    then
      dec (y1)
    else
      if (y1 < y2)
      then
        inc (y1);
      {endif}
    {endif}
  until ((x1 = x2) and (y1 = y2));
end; { line }

procedure barre (x, y, largeur, hauteur : word; c : byte);
var
   i : word;
begin
  for i := 1 to hauteur do
    line (x, pred (y+i), pred (x+largeur), pred (y+i), c);
  {endfor}
end; { barre }

procedure affiche_carre (first, indice: byte);
begin
  textattr := white;
  gotoxy (16, 3);
  write (#219#219#219#219);
  gotoxy (16, 4);
  write (#219#219#219#219);
  gotoxy (16, 5);
  write (#219#219#219#219);
  gotoxy (16, 6);
  write (#219#219#219#219);
  textattr := indice+100;
  gotoxy (17, 4);
  write (#177#177);
  gotoxy (17, 5);
  write (#177#177);
  textattr := yellow;
  gotoxy (17, 7);
  write (first+indice : 3);
end; { affiche_carre }

procedure affiche_fleche (first, indice, oi : byte);
begin
  textattr := white;
  gotoxy (35, 2+oi);
  write ('  ');
  gotoxy (35, 2+indice);
  write ('->');
  affiche_carre (first, indice);
end; { affiche_fleche }

procedure affiche_ascenseur (first, indice, oi : byte);
var
   i : byte;
begin
  pal2prog (pal, p, first);
  for i := 0 to 22 do
    begin
      textattr := 100+i;
      gotoxy (37, 2+i);
      write (#219, first+i : 3);
    end;
  {endfor}
  affiche_fleche (first, indice, oi);
end; { affiche_ascenseur }

procedure affiche_r (first, indice : byte);
var
   v : byte;
begin
  v := p [indice].r;
  if (v > 63)
  then
    begin
      v := 63;
      p [indice].r := 63;
    end;
  {endif}
  textattr := red;
  gotoxy (2, 25);
  write ('   ');
  gotoxy (2, 25);
  write (v:3);
  barre (10, 56, 20, 128-v*2, lightgray);
  barre (10, 184-v*2, 20, v*2, red);
end; { affiche_r }

procedure affiche_v (first, indice : byte);
var
   v : byte;
begin
  v := p [indice].v;
  if (v > 63)
  then
    begin
      v := 63;
      p [indice].v := 63;
    end;
  {endif}
  textattr := green;
  gotoxy (6, 25);
  write ('   ');
  gotoxy (6, 25);
  write (v:3);
  barre (42, 56, 20, 128-v*2, lightgray);
  barre (42, 184-v*2, 20, v*2, green);
end; { affiche_v }

procedure affiche_b (first, indice : byte);
var
   v : byte;
begin
  v := p [indice].b;
  if (v > 63)
  then
    begin
      v := 63;
      p [indice].b := 63;
    end;
  {endif}
  textattr := blue;
  gotoxy (10, 25);
  write ('   ');
  gotoxy (10, 25);
  write (v:3);
  barre (74, 56, 20, 128-v*2, lightgray);
  barre (74, 184-v*2, 20, v*2, blue);
end; { affiche_b }

procedure triangle_haut (x, y : word);
var
   i : byte;
begin
  barre (x*8-8, y*8-8, 24, 8, white);
  for i := 1 to 6 do
    line (x*8+4-pred (i)*2, y*8-8+i, x*8+4+pred (i)*2, y*8-8+i, lightgray);
  {endfor}
end; { triangle_haut }

procedure triangle_bas (x, y : word);
var
   i : byte;
begin
  barre (x*8-8, y*8-8, 24, 8, white);
  for i := 1 to 6 do
    line (x*8+4-pred (i)*2, y*8-i-1, x*8+4+pred (i)*2, y*8-i-1, lightgray);
  {endfor}
end; { triangle_bas }

procedure dessin_ecran (nom : string; first, indice : byte);
begin
  repeat
  until (set_mode (19));
  textattr := yellow;
  gotoxy (1, 1);
  write ('PAL Maker:', nom);
  textattr := red;
  gotoxy (3, 5);
  write ('R');
  gotoxy (1, 7);
  write ('7');
  gotoxy (1, 24);
  write ('1');
  textattr := green;
  gotoxy (7, 5);
  write ('G');
  gotoxy (5, 7);
  write ('8');
  gotoxy (5, 24);
  write ('2');
  textattr := blue;
  gotoxy (11, 5);
  write ('B');
  gotoxy (9, 7);
  write ('9');
  gotoxy (9, 24);
  write ('3');
  textattr := 15;
  gotoxy (14, 10);
  write ('F2  - Save');
  gotoxy (14, 18);
  write ('F10 - Test');
  gotoxy (14, 19);
  write ('ESC - Exit');
  textattr := lightgray;
  gotoxy (33, 1);
  write ('PgUp');
  gotoxy (33, 25);
  write ('PgDn');
  triangle_haut (2, 7);
  triangle_haut (6, 7);
  triangle_haut (10, 7);
  triangle_haut (38, 1);
  triangle_bas (2, 24);
  triangle_bas (6, 24);
  triangle_bas (10, 24);
  triangle_bas (38, 25);
  affiche_ascenseur (first, indice, 0);
  affiche_r (first, indice);
  affiche_v (first, indice);
  affiche_b (first, indice);
end; { dessin_ecran }

procedure affiche_test;
var
   i : word;
begin
  get_blk_cna_reg (0, 256, p);
  repeat
  until (set_mode (19) or true);
  set_blk_cna_reg (0, 256, pal^);
  for i := 0 to 511 do
    line (i, 0, 0, i, i div 2);
  {endfor}
  alert ('', al_nothing);
  repeat
  until (set_mode (19) or true);
  set_blk_cna_reg (0, 256, p);
end; { affiche_test }

procedure modify (nom : string);
var
   first,
   old_first,
   indice,
   oi,
   b : byte;
   c : char;
   code_nul,
   fin : boolean;
begin
  first := 0;
  old_first := first;
  indice := 0;
  oi := indice;
  pal2prog (pal, p, first);
  dessin_ecran (nom, first, indice);
  repeat
    fin := false;
    if (zone <> nil)
    then
      zone^.test_graph (code_nul, c)
    else
      begin
        c := readkey;
        code_nul := (c = carac_nul);
        if (code_nul)
        then
          c := readkey;
        {endif}
      end;
    {endif}
    if (code_nul)
    then
      case c of
        touche_page_up :
          if (first > 23)
          then
            dec (first, 23)
          else
            first := 0;
          {endif}
        touche_page_dn :
          if (first+23 < 256-23)
          then
            inc (first, 23)
          else
            first := 256-23;
          {endif}
        touche_haut :
          if (indice > 0)
          then
            dec (indice)
          else
            indice := 22;
          {endif}
        touche_bas :
          if (indice < 22)
          then
            inc (indice)
          else
            indice := 0;
          {endif}
        touche_f2 :
          begin
            prog2pal (pal, p, first);
            save_pal (nom, pal);
          end;
        touche_f10 :
          begin
            prog2pal (pal, p, first);
            affiche_test;
            pal2prog (pal, p, first);
            dessin_ecran (nom, first, indice);
          end;
        #200..#222 : indice := ord (c)-200;
        #250..#252 :
          begin
            b := (184 - pos_m_y) div 2;
            case c of
              #250 :
                begin
                  p [indice].r := b;
                  affiche_r (first, indice);
                end;
              #251 :
                begin
                  p [indice].v := b;
                  affiche_v (first, indice);
                end;
              #252 :
                begin
                  p [indice].b := b;
                  affiche_b (first, indice);
                end;
            end;
            set_cna_reg (100+indice, p [indice].v, p [indice].b, p [indice].r);
          end;
      end
    else
      case upcase (c) of
        touche_escape : fin := true;
        '7' :
          begin
            b := p [indice].r;
            if (b < 63)
            then
              begin
                inc (p [indice].r);
                affiche_r (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                        p [indice].b,
                                        p [indice].r);
              end;
            {endif}
          end;
        '8' :
          begin
            b := p [indice].v;
            if (b < 63)
            then
              begin
                inc (p [indice].v);
                affiche_v (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                         p [indice].b,
                                         p [indice].r);
              end;
            {endif}
          end;
        '9' :
          begin
            b := p [indice].b;
            if (b < 63)
            then
              begin
                inc (p [indice].b);
                affiche_b (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                         p [indice].b,
                                         p [indice].r);
              end;
            {endif}
          end;
        '1' :
          begin
            b := p [indice].r;
            if (b > 0)
            then
              begin
                dec (p [indice].r);
                affiche_r (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                         p [indice].b,
                                         p [indice].r);
              end;
            {endif}
          end;
        '2' :
          begin
            b := p [indice].v;
            if (b > 0)
            then
              begin
                dec (p [indice].v);
                affiche_v (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                         p [indice].b,
                                         p [indice].r);
              end;
            {endif}
          end;
        '3' :
          begin
            b := p [indice].b;
            if (b > 0)
            then
              begin
                dec (p [indice].b);
                affiche_b (first, indice);
                set_cna_reg (100+indice, p [indice].v,
                                         p [indice].b,
                                         p [indice].r);
              end;
            {endif}
          end;
      end;
    {endif}
    if ((old_first <> first) or (oi <> indice))
    then
      begin
        prog2pal (pal, p, old_first);
        if (first <> old_first)
        then
          affiche_ascenseur (first, indice, oi)
        else
          affiche_fleche (first, indice, oi);
        {endif}
        affiche_r (first, indice);
        affiche_v (first, indice);
        affiche_b (first, indice);
        old_first := first;
        oi := indice;
      end;
    {endif}
  until fin;
end; { modify }

procedure traitement (nom : string);
begin
  pal := load_pal (nom);
  if (pal = nil)
  then
    begin
      new (pal);
      if (pal <> nil)
      then
        get_blk_cna_reg (0, 256, pal^);
      {endif}
    end;
  {endif}
  if (pal <> nil)
  then
    begin
      modify (nom);
      dispose (pal);
    end;
  {endif}
end; { traitement }

procedure init_zones;
var
   i : byte;
begin
{ Touches de contr“le (menu). }
  zone^.add_graph (112, 72, 80, 8, true, touche_f2);
  zone^.add_graph (112, 136, 80, 8, true, touche_f10);
  zone^.add_graph (112, 144, 80, 8, false, touche_escape);
{ Barres de couleur. }
  zone^.add_graph (8, 48, 24, 8, false, '7');
  zone^.add_graph (40, 48, 24, 8, false, '8');
  zone^.add_graph (72, 48, 24, 8, false, '9');
  zone^.add_graph (8, 184, 24, 8, false, '1');
  zone^.add_graph (40, 184, 24, 8, false, '2');
  zone^.add_graph (72, 184, 24, 8, false, '3');
{ Barres de couleurs. }
  zone^.add_graph (10, 56, 30, 128, true, #250); { Rouge }
  zone^.add_graph (42, 56, 30, 128, true, #251); { Vert }
  zone^.add_graph (74, 56, 30, 128, true, #252); { Bleu }
{ Changement de page de couleur. }
  zone^.add_graph (296, 0, 24, 8, true, touche_page_up);
  zone^.add_graph (296, 192, 24, 8, true, touche_page_dn);
{ Indices dans la colonne de droite. }
  for i := 0 to 22 do
    zone^.add_graph (288, 8+i*8, 31, 8, true, chr (200+i));
  {endfor}
end; { init_zones }

var
   om : byte;
   i : byte;

begin
  directvideo := false;
  writeln ('PAL Color Maker (', num_ver, ')');
  writeln ('(c) Olf Software ', dat_ver);
  if (paramcount = 0)
  then
    begin
      writeln;
      writeln ('To use this program, type:');
      writeln;
      writeln ('     MKPAL Fich_Name.PAL');
      writeln;
    end
  else
    begin
      init_licence ('MKCOLOR');
      init_olf_message (mess_freeware);
      init_olf_software ('PAL Color Maker '+num_ver, '(c) Patrick Premartin '+dat_ver);
      zone := new (p_m_zone, init);
      init_zones;
      om := get_mode;
      if not (set_mode (19))
      then
        begin
          writeln ('MCGA/VGA Color needed. I can not access 320*200 pixels, 256 Colors...');
          halt (1);
        end;
      {endif}
      i := paramcount;
      while (i > 0) do
        begin
          traitement (paramstr (i));
          dec (i);
        end;
      {endwhile}
      dispose (zone, done);
      repeat
      until ((set_mode (om)) or true);
    end;
  {endif}
end.
