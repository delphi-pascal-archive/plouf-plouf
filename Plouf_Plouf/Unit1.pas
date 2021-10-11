unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin;

type
  TForm1 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    BtnQuit: TButton;
    Label1: TLabel;
    SEforce: TSpinEdit;
    BtnTsunami: TButton;
    CBVagues: TCheckBox;
    procedure Timer1Timer(Sender: TObject);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure BtnQuitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SEforceChange(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnTsunamiClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;



implementation

{$R *.dfm}
const
 maxcailloux=5;

type
 ttab=array[0..0] of integer;
 ptab=^ttab;
 TPoscailloux=array[1..maxcailloux] of TRect;

const
 tablecailloux:TPoscailloux=      //place des cailloux dans l'image originale
 ((Left:000; Top:0; Right:058; Bottom:76)
 ,(Left:059; Top:0; Right:140; Bottom:64)
 ,(Left:141; Top:0; Right:210; Bottom:69)
 ,(Left:211; Top:0; Right:289; Bottom:76)
 ,(Left:290; Top:0; Right:340; Bottom:106));


var
 bitinfo:TBitmapInfo;       // structure pour getdibits et setdibits
 im:ptab;                   // buffer contenant 4 images
                            // 1 - l'image du sable
                            // 2 - un buffer pour le rendu avec els vagues
                            // 3 et 4 - les deux buffers pour le calcul des vagues seul
 cailloux:ptab;             // buffer de l'image des cailloux
 poscailloux:TPoscailloux;  // positions des cailloux
 cwi,che:integer;           // taille du buffer des cailloux
 cpt:byte=0;                // compteur pour le flip entre les deux buffers de vagues
 wi,he:integer;             // taille de l'image du sable
 puissance:integer=500;     // force des vagues
 mx,my,mc:integer;          // position de la souris



procedure TForm1.Timer1Timer(Sender: TObject);
var
 cp,sp:integer;
 i,j:integer;
 wn:integer;
 nw:dword;
 dx,dy:integer;

 // cherche le pixel (x,y), soit sur le sable, soit sur un cailloux
 function getpix(x,y:integer):integer;
 var tx,ty,k:integer;
 begin
  result:=im[x+y*wi];;
  for k:=1 to maxcailloux do
   if (x>=poscailloux[k].Left) and (y>=poscailloux[k].Top)
   and (x<=poscailloux[k].Right) and (y<=poscailloux[k].Bottom)
   then
    begin
     tx:=x-poscailloux[k].Left+tablecailloux[k].Left;
     ty:=y-poscailloux[k].Top+tablecailloux[k].top;
     if cailloux[tx+cwi*ty]<>$FF00FF then
      result:=cailloux[tx+cwi*ty];
    end;
 end;

begin
 // mise à jour des vagues
 // une sorte de moyenne de l'état d'avant et de l'état présent
 cp:=wi*he*2+cpt*wi*he;
 sp:=wi*he*2+(1-cpt)*wi*he;
 for i:=1 to he-2 do
  begin
  wn:=i*wi;
  for j:=1 to wi-2 do
   begin
    inc(wn);
    nw:=((im[cp+wn-wi-1]+
         im[cp+wn-wi]+
         im[cp+wn-wi+1]+
         im[cp+wn-1]+
         im[cp+wn+1]+
         im[cp+wn+wi-1]+
         im[cp+wn+wi]+
         im[cp+wn+wi+1]) shr 2)-im[sp+wn];
    im[sp+wn]:=nw;
    if im[sp+wn]<0 then  im[sp+wn]:=0;
   end;
  end;

  // si on veux affiche le sable et les cailloux
 if not CBVagues.Checked then
  begin
 for i:=1 to he-2 do
  begin
  wn:=i*wi;
  for j:=1 to wi-2 do
   begin
    inc(wn);
    // calcul du décalage entre l'image orginal et l'image affiché
    dx:=im[sp+wn]-im[sp+wn+wi];
    dy:=im[sp+wn]-im[sp+wn+1];
    dx:=dx div 4+j; if dx>=wi then dx:=wi-1; if dx<0 then dx:=0;
    dy:=dy div 4+i; if dy>=he then dy:=he-1; if dy<0 then dy:=0;

    im[wi*he+j+i*wi]:=getpix(dx,dy);
   end;
  end;
 // on transfert tout les bits du buffer à l'image
 SetDIBits(image1.Canvas.Handle,image1.Picture.Bitmap.Handle,0,he,@(im[wi*he]),bitinfo,DIB_RGB_COLORS);
 end
 else        // on transfert tout les bits du buffer de vague à l'image
 SetDIBits(image1.Canvas.Handle,image1.Picture.Bitmap.Handle,0,he,@(im[sp]),bitinfo,DIB_RGB_COLORS);
 // on met à jour l'image
 image1.Refresh;
 cpt:=1-cpt;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
 i,j:integer;
 bit:tbitmap;
begin
 mc:=0;
 poscailloux:=tablecailloux;

 bit:=tbitmap.create;
 // charge l'image des cailloux
 bit.LoadFromFile('images\cailloux.bmp');
 bit.PixelFormat:=pf32bit;
 // alloue la mémoire pour le buffer
 getmem(cailloux,bit.Width*bit.Height*4);
 cwi:=bit.Width;
 che:=bit.Height;
 // construit la structure BitInfo
 with bitinfo.bmiHeader do
  begin
        biSize := sizeof(bitinfo.bmiHeader);
        biWidth := bit.width;
        biHeight := -bit.Height;
        biPlanes := 1;
        biBitCount := 32;
        biCompression := BI_RGB;
        biSizeImage := 0;
        biXPelsPerMeter := 1; //dont care
        biYPelsPerMeter := 1; //dont care
        biClrUsed := 0;
        biClrImportant := 0;
 End;
 // trnasfert les bits de l'image directement en mémoire
 GetDIBits(bit.Canvas.Handle,bit.Handle,0,bit.Height,cailloux,bitinfo,DIB_RGB_COLORS);

 // la même chose avec le sable
 image1.Picture.Bitmap:=tbitmap.Create;
 image1.Picture.Bitmap.LoadFromFile('images\sable.bmp');
 wi:=image1.Width;
 he:=image1.Height;
 getmem(im,wi*he*4*4);

  with bitinfo.bmiHeader do
 begin
        biWidth := wi;
        biHeight := -he;
        biSizeImage := 0;
 End;
 // transfert des bits de l'image du sable direct en mémoire dans le buffer
 GetDIBits(image1.Canvas.Handle,image1.Picture.Bitmap.Handle,0,he,im,bitinfo,DIB_RGB_COLORS);

 // met à zéro le buffer de vague
 fillchar(im[wi*he*2],wi*he*4*2,0);
 timer1.Enabled:=true;
end;

procedure TForm1.BtnQuitClick(Sender: TObject);
begin
close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
timer1.Enabled:=false;
//on libère les deux buffers
freemem(im);
freemem(cailloux);
end;

procedure TForm1.SEforceChange(Sender: TObject);
begin
 try
  puissance:=SEforce.Value;
 except
  puissance:=1000;
 end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 tx,ty,k:integer;
begin
 // on sauve les coordonnées
 mx:=x;
 my:=y;
 mc:=0;
 // on cherche si il y a un cailloux sous la souris
 for k:=1 to maxcailloux do
  if (x>=poscailloux[k].Left) and (y>=poscailloux[k].Top)
   and (x<=poscailloux[k].Right) and (y<=poscailloux[k].Bottom)
   then
    begin
     tx:=x-poscailloux[k].Left+tablecailloux[k].Left;
     ty:=y-poscailloux[k].Top+tablecailloux[k].top;
     if cailloux[tx+cwi*ty]<>$FF00FF then mc:=k;
    end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
if x<1 then exit;
if y<1 then exit;
if x>wi-2 then exit;
if y>he-2 then exit;

 im[wi*he*2+wi*y+x]:=puissance;
 im[wi*he*2+wi*y+x+1]:=puissance shr 1;
 im[wi*he*2+wi*y+x-1]:=puissance shr 1;
 im[wi*he*2+wi*y+x+wi]:=puissance shr 1;
 im[wi*he*2+wi*y+x-wi]:=puissance shr 1;

 // si il y a un cailloux de selectionné, on le déplace
 if mc=0 then exit;
 mx:=x-mx;
 my:=y-my;
 poscailloux[mc].Left:=poscailloux[mc].Left+mx;
 poscailloux[mc].Right:=poscailloux[mc].Right+mx;
 poscailloux[mc].top:=poscailloux[mc].top+my;
 poscailloux[mc].Bottom:=poscailloux[mc].Bottom+my;
 mx:=x;
 my:=y;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if mc=0 then exit;
 // si il y a un cailloux de selectionné, on le déplace
 x:=x-mx;
 y:=y-my;
 poscailloux[mc].Left:=poscailloux[mc].Left+x;
 poscailloux[mc].Right:=poscailloux[mc].Right+x;
 poscailloux[mc].top:=poscailloux[mc].top+y;
 poscailloux[mc].Bottom:=poscailloux[mc].Bottom+y;
 mc:=0;
end;

procedure TForm1.BtnTsunamiClick(Sender: TObject);
var
 i:integer;
begin
// crée une grosse vague au centre...
 for i:=0 to he-1 do
  begin
   im[wi*he*2+wi*i+wi div 2]:=puissance*2;
   im[wi*he*2+wi*i+wi div 2-1]:=puissance ;
   im[wi*he*2+wi*i+wi div 2+1]:=puissance ;
  end;
end;

end.
