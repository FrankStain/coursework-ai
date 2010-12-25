unit MUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  MapUnit, AIUnit,
  Dialogs, Menus, StdCtrls, ComCtrls, ExtCtrls, Spin;

type
  TMForm = class(TForm)
    P_Screen: TPanel;
    PC_Game: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    GroupBox1: TGroupBox;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    SE_MapY: TSpinEdit;
    SE_MapX: TSpinEdit;
    SetMapSizeButton: TButton;
    GroupBox2: TGroupBox;
    FlushMapButton: TButton;
    ShakeMapButton: TButton;
    PB_Screen: TPaintBox;
    B_AI1Start: TButton;
    LB_AI1WayList: TListBox;
    B_AI1Step: TButton;
    Bevel1: TBevel;
    B_AI1Reset: TButton;
    Bevel2: TBevel;
    B_AI1ClearList: TButton;
    P_Process: TPanel;
    StaticText7: TStaticText;
    Label1: TLabel;
    L_AI1SCount: TLabel;
    Label3: TLabel;
    L_AI1STotal: TLabel;
    Label2: TLabel;
    P_Process3: TPanel;
    Label4: TLabel;
    L_AI3SCount: TLabel;
    Label6: TLabel;
    L_AI3STotal: TLabel;
    Label8: TLabel;
    StaticText8: TStaticText;
    B_AI3ClearList: TButton;
    B_AI3Reset: TButton;
    B_AI3Step: TButton;
    LB_AI3WayList: TListBox;
    B_AI3Start: TButton;
    Bevel3: TBevel;
    Bevel4: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PB_ScreenPaint(Sender: TObject);
    procedure PB_ScreenMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SetMapSizeButtonClick(Sender: TObject);
    procedure FlushMapButtonClick(Sender: TObject);
    procedure ShakeMapButtonClick(Sender: TObject);
    procedure PB_ScreenMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure B_AI1StartClick(Sender: TObject);
    procedure B_AI1ClearListClick(Sender: TObject);
    procedure B_AI1ResetClick(Sender: TObject);
    procedure B_AI1StepClick(Sender: TObject);
    procedure B_AI3StartClick(Sender: TObject);
    procedure B_AI3ResetClick(Sender: TObject);
    procedure B_AI3StepClick(Sender: TObject);
    procedure B_AI3ClearListClick(Sender: TObject);
  private
    { Private declarations }
    GameMap: TMap;
    oBasicMap: TMap;
    oWideAI: TWidewayAI;
    oWideWay: TWaypointList;
    oGradientAI: TGradientAI;
    oGradientWay: TWaypointList;

    Procedure AI1Process(iStep: integer; iMax: integer);
    Procedure AI3Process(iStep: integer; iMax: integer);
  public
    { Public declarations }
  end;

var
  MForm: TMForm;
  MousePoint: TPoint;
  bMouseCellActive: boolean;

implementation

uses Math;

{$R *.dfm}

const
  clGameBackground: TColor = $00B88B7B;
  clGameActiveCell: TColor = clSkyBlue;

procedure TMForm.FormCreate(Sender: TObject);
begin
  randomize;
  DoubleBuffered := true;
  GameMap := Tmap.Create;
  PC_Game.ActivePageIndex := 0;
  P_Screen.Color := clGameBackground;

  oWideAI := TWidewayAI.Create;
  oWideWay := TWaypointList.Create;
  oWideAI.OnProcess := AI1Process;

  {задаме для метода поиска по градиенту
  основные списки}
  oGradientAI := TGradientAI.Create;
  oGradientWay := TWaypointList.Create;
  oGradientAI.OnProcess := AI3Process;
end;

procedure TMForm.FormDestroy(Sender: TObject);
begin
  oGradientWay.Free;
  oGradientAI.Free;
  oWideWay.Free;
  oWideAI.Free;
  GameMap.Free;
end;

procedure TMForm.FormShow(Sender: TObject);
begin
  SE_MapX.Value := GameMap.Width;//ширина поля
  SE_MapY.Value := GameMap.Height;//высота поля
  PB_Screen.Color := clGameBackground;
  SetMapSizeButton.Click;//функция задания размера поля
end;

{процедура перерисовки изображения}
procedure TMForm.PB_ScreenPaint(Sender: TObject);
var
  x, y, cs, ms: integer;
  dr: TRect;
  sDigit: string;
begin
  if GameMap.IsValid then P_Screen.Color := clGameActiveCell
  else P_Screen.Color := clGameBackground;
  with TPaintBox(Sender).Canvas do
  begin
    Font.Name := 'Arial';//задаем шрифт цифр
    Font.Style := [fsBold];//толщину
    Pen.Color := clBlack;//цвет
    ms := ClipRect.Right - ClipRect.Left;
    cs := ms div GameMap.Width;
    ms := (ms mod GameMap.Width) div 2;
    Font.Size := (cs div 2) - 1;
    for y := 0 to GameMap.Height -1 do begin
      for x := 0 to GameMap.Width - 1 do begin
        dr := Bounds(ms + x * cs , ms + y * cs, cs, cs);
        if bMouseCellActive and ((MousePoint.X = x) and (MousePoint.Y = y)) then Brush.Color := clGameActiveCell
        else Brush.Color := clGameBackground;
        Rectangle(dr);//рисуем прямоуголник (клеточка-фишка)
        if GameMap.Cell[x, y] <> 0 then begin//если не пустышка, то
          sDigit := IntToStr(GameMap.Cell[x, y]);//получаем число фишки
          inc(dr.Left, (cs - TextWidth(sDigit)) div 2);
          inc(dr.Top, (cs - TextHeight(sDigit)) div 2);
          Brush.Style := bsClear;
          TextOut(dr.Left, dr.Top, sDigit);//пишем цифру в клеточке
          Brush.Style := bsSolid;
        end;
      end;
    end;
  end;
end;

{процедура при перемещении мыши по полю}
procedure TMForm.PB_ScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  cs: integer;
  dm: TPoint;
begin
  with TPaintBox(Sender).Canvas do begin
    cs := (ClipRect.Right - ClipRect.Left) div GameMap.Width;
    dm := Point(X div cs, Y div cs);
    if (dm.X <> MousePoint.X) or (dm.Y <> MousePoint.Y) then begin
      bMouseCellActive := GameMap.IsCellMovable(dm.X, dm.Y);
      MousePoint := dm;
      PB_Screen.Repaint;
    end;
  end;
end;

{функция изменения размера поля}
procedure TMForm.SetMapSizeButtonClick(Sender: TObject);
begin
  SE_MapY.Value := SE_MapX.Value;//размер поля строго квадратной формы
  GameMap.SetSize(SE_MapX.Value, SE_MapY.Value);//задание размера карты
  FlushMapButton.Click;
  PB_Screen.Repaint;//перерисовка
end;

{процедура сбрасывания поля
упорядочивает фишки в верном порядке}
procedure TMForm.FlushMapButtonClick(Sender: TObject);
var
  x, y: integer;
begin
  with GameMap do begin
    for y := 0 to Height - 1 do begin
      for x := 0 to Width - 1 do begin
        Cell[x, y] := (y * Height) + x + 1;
      end;
    end;
    Cell[Width - 1, Height - 1] := 0;
  end;
  //перерисовываем поле
  PB_Screen.Repaint;
end;

{обработчик нажатия на кнопку "Перемещать фишки"}
procedure TMForm.ShakeMapButtonClick(Sender: TObject);
var
  iStep, iRndCell: integer;
  ptEmptyCell: TPoint;
begin
  iStep := 0;
  while iStep < 4 * (GameMap.Width + 1) do begin
    ptEmptyCell := GameMap.GetEmptyCell;//определяем коорилднаты пустой фишки
    iRndCell := random(64) mod 4;//генерируем случанойе число
    inc(ptEmptyCell.X, arMoveDirections[iRndCell, 0]);
    inc(ptEmptyCell.Y, arMoveDirections[iRndCell, 1]);
    if ptEmptyCell.X < 0 then ptEmptyCell.X := 0 - ptEmptyCell.X;
    if ptEmptyCell.Y < 0 then ptEmptyCell.Y := 0 - ptEmptyCell.Y;
    if not GameMap.MoveCell(ptEmptyCell.X, ptEmptyCell.Y) then continue;//если нельзя
    //переместить фищку по данным координатам, то идем дальше

    //если построился выигрыш, то нужно еще мешать фишки
    if GameMap.IsValid then dec(iStep)
                       else inc(iStep);
  end;

  PB_Screen.Repaint;
end;

procedure TMForm.PB_ScreenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not (bMouseCellActive and (PC_Game.ActivePageIndex = 0)) then exit;
  GameMap.MoveCell(MousePoint.X, MousePoint.Y);
  MousePoint := Point(0, 0);
  PB_ScreenMouseMove(Sender, Shift, X, Y);
  PB_Screen.Repaint;
end;

procedure TMForm.B_AI1StartClick(Sender: TObject);
var
  iWaypointId: integer;
  oPoint: TWaypoint;
begin
  B_AI1ClearList.Click;
  P_Process.Visible := true;
  oWideAI.Process(GameMap);
  if oWideAI.GetRightPass(oWideWay) then begin
    if oBasicMap <> nil then oBasicMap.Free;
    oBasicMap := GameMap.Peer;
    LB_AI1WayList.Clear;
    iWaypointId := 0;
    while iWaypointId < oWideWay.Count do begin
      oPoint := oWideWay.Point[iWaypointId];
      LB_AI1WayList.Items.AddObject(format('Ход [%d, %d]', [oPoint.X + 1, oPoint.Y + 1]), oPoint);
      inc(iWaypointId);
    end;
  end;
  //P_Process.Visible := false;
end;

procedure TMForm.B_AI1ClearListClick(Sender: TObject);
begin
  LB_AI1WayList.Clear;
  oWideWay.Clear;
  oWideAI.Clear;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  GameMap.ClearPeers;
  oBasicMap := nil;
  PB_Screen.Repaint;
end;

procedure TMForm.B_AI1ResetClick(Sender: TObject);
begin
  LB_AI1WayList.Tag := -1;
  LB_AI1WayList.ItemIndex :=  -1;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  PB_Screen.Repaint;
end;

procedure TMForm.B_AI1StepClick(Sender: TObject);
var
  oPoint: TWaypoint;
begin
  if GameMap.IsValid or (1 > LB_AI1WayList.Count) then exit;
  if LB_AI1WayList.Tag <> LB_AI1WayList.ItemIndex then B_AI1Reset.Click;
  LB_AI1WayList.ItemIndex := LB_AI1WayList.ItemIndex + 1;
  oPoint := TWaypoint(LB_AI1WayList.Items.Objects[LB_AI1WayList.ItemIndex]);
  GameMap.MoveCell(oPoint.X, oPoint.Y);
  PB_Screen.Repaint;
  LB_AI1WayList.Tag := LB_AI1WayList.ItemIndex;
end;

Procedure TMForm.AI1Process(iStep: integer; iMax: integer);
begin
  L_AI1SCount.Caption := IntToStr(iStep);
  L_AI1STotal.Caption := IntToStr(iMax);
  Application.ProcessMessages;
end;

Procedure TMForm.AI3Process(iStep: integer; iMax: integer);
begin
  L_AI3SCount.Caption := IntToStr(iStep);
  L_AI3STotal.Caption := IntToStr(iMax);
  Application.ProcessMessages;
end;

procedure TMForm.B_AI3StartClick(Sender: TObject);
var
  iWaypointId: integer;
  oPoint: TWaypoint;
begin
  B_AI3ClearList.Click;
  P_Process3.Visible := true;
  oGradientAI.Process(GameMap);
  if oGradientAI.GetRightPass(oGradientWay) then begin
    if oBasicMap <> nil then oBasicMap.Free;
    oBasicMap := GameMap.Peer;
    LB_AI3WayList.Clear;
    iWaypointId := 0;
    while iWaypointId < oGradientWay.Count do begin
      oPoint := oGradientWay.Point[iWaypointId];
      LB_AI3WayList.Items.AddObject(format('Ход [%d, %d]', [oPoint.X + 1, oPoint.Y + 1]), oPoint);
      inc(iWaypointId);
    end;
  end;
  //P_Process3.Visible := false;
end;

procedure TMForm.B_AI3ResetClick(Sender: TObject);
begin
  LB_AI3WayList.Tag := -1;
  LB_AI3WayList.ItemIndex :=  -1;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  PB_Screen.Repaint;
end;

procedure TMForm.B_AI3StepClick(Sender: TObject);
var
  oPoint: TWaypoint;
begin
  if GameMap.IsValid or (1 > LB_AI1WayList.Count) then exit;
  if LB_AI3WayList.Tag <> LB_AI3WayList.ItemIndex then B_AI3Reset.Click;
  LB_AI3WayList.ItemIndex := LB_AI3WayList.ItemIndex + 1;
  oPoint := TWaypoint(LB_AI3WayList.Items.Objects[LB_AI3WayList.ItemIndex]);
  GameMap.MoveCell(oPoint.X, oPoint.Y);
  PB_Screen.Repaint;
  LB_AI3WayList.Tag := LB_AI3WayList.ItemIndex;
end;

procedure TMForm.B_AI3ClearListClick(Sender: TObject);
begin
  LB_AI3WayList.Clear;
  oWideWay.Clear;
  oWideAI.Clear;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  GameMap.ClearPeers;
  oBasicMap := nil;
  PB_Screen.Repaint;
end;

end.
