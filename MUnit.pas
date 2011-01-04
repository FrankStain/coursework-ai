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
    P_Process2: TPanel;
    Label5: TLabel;
    L_AI2SCount: TLabel;
    Label9: TLabel;
    L_AI2STotal: TLabel;
    Label11: TLabel;
    StaticText9: TStaticText;
    B_AI2ClearList: TButton;
    B_AI2Reset: TButton;
    B_AI2Step: TButton;
    LB_AI2WayList: TListBox;
    B_AI2Start: TButton;
    Bevel5: TBevel;
    Bevel6: TBevel;
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
    procedure B_AI2StartClick(Sender: TObject);
    procedure B_AI2ResetClick(Sender: TObject);
    procedure B_AI2StepClick(Sender: TObject);
    procedure B_AI2ClearListClick(Sender: TObject);
  private
    { Private declarations }
    GameMap: TMap;               // поле, которое и отображается пользователю
    oBasicMap: TMap;             // это копия GameMap
    oWideAI: TWidewayAI;         // объект для поиска в ширину
    oWideWay: TWaypointList;     // список ходов, найденых с помощью поиска в ширину
    oGradientAI: TGradientAI;    // объект для поиска по градиенту
    oGradientWay: TWaypointList; // список ходов, найденых с помощью поиска по градиенту
    oDeepAI: TDeepwayAI;         // объект для поиска в глубину
    oDeepWay: TWaypointList;     // список ходов, найденных с помощью поиска в глубину

    // Методы отклика для процессов поиска
    Procedure AI1Process(iStep: integer; iMax: integer);
    Procedure AI2Process(iStep: integer; iMax: integer);
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
  clGameActiveCell: TColor = clSkyBlue;//цвет когда ячейка активна

procedure TMForm.FormCreate(Sender: TObject);
begin
  randomize;
  DoubleBuffered := true;//разрешаем двойной буффер, изображение вначале рисуется во временный буфер
  //а затем махом вырисовывается
  GameMap := Tmap.Create;//создание карты
  PC_Game.ActivePageIndex := 0;
  P_Screen.Color := clGameBackground;//устанавливаем основной цвет

  oWideAI := TWidewayAI.Create;
  oWideWay := TWaypointList.Create;
  oWideAI.OnProcess := AI1Process;//создаем процесс поиска в ширину

  {задаем для метода поиска по градиенту
  основные списки}
  oGradientAI := TGradientAI.Create;
  oGradientWay := TWaypointList.Create;
  oGradientAI.OnProcess := AI3Process;

  oDeepAI := TDeepwayAI.Create;
  oDeepWay := TWaypointList.Create;
  oDeepAI.OnProcess := AI2Process;
end;

procedure TMForm.FormDestroy(Sender: TObject);
begin
 //очистка основных списков
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
  PB_Screen.Color := clGameBackground;//цвет
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
    ms := ClipRect.Right - ClipRect.Left;//определяем область рисования
    //ClipRect  - прямоуголная область для рисования
    //ширину прямоуголника

    cs := ms div GameMap.Width;//ширину области рисования делим на карту поля игры, определяем размер клеточки
    ms := (ms mod GameMap.Width) div 2;//определяется начало поля относительно начала канвы
    Font.Size := (cs div 2) - 1;//высота шрифта
    for y := 0 to GameMap.Height -1 do begin
      for x := 0 to GameMap.Width - 1 do begin
        dr := Bounds(ms + x * cs , ms + y * cs, cs, cs);//Bounds определяет рамку
        //координаты:
        //ось X и ось Y
        //ширина и высота

        //если ячейка активна(выделена мышью) то помечаем другим цветом
        if bMouseCellActive and ((MousePoint.X = x) and (MousePoint.Y = y)) then Brush.Color := clGameActiveCell
        else Brush.Color := clGameBackground;
        Rectangle(dr);//рисуем прямоуголник (клеточка-фишка)
        if GameMap.Cell[x, y] <> 0 then begin//если не пустышка, то
          sDigit := IntToStr(GameMap.Cell[x, y]);//получаем число фишки
          inc(dr.Left, (cs - TextWidth(sDigit)) div 2);//определяем коориданту для рисования цифры
          inc(dr.Top, (cs - TextHeight(sDigit)) div 2);//определяем коорлинату для рисования цифры
          Brush.Style := bsClear;
          TextOut(dr.Left, dr.Top, sDigit);//пишем цифру в клеточке
          Brush.Style := bsSolid;
        end;
      end;
    end;
  end;
end;

{процедура при перемещении мыши по полю }
procedure TMForm.PB_ScreenMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  cs: integer;
  dm: TPoint;
begin
  with TPaintBox(Sender).Canvas do begin
    cs := (ClipRect.Right - ClipRect.Left) div GameMap.Width;//определяем размер клетки
    dm := Point(X div cs, Y div cs);//определяем коорлинаты где находится мышь
    
    {перерисовку осуществляем только тогда, когда мышь пермещается над фишкой
    которую можно свдинуть или уходит с нее}
    if (dm.X <> MousePoint.X) or (dm.Y <> MousePoint.Y) then
    begin
      bMouseCellActive := GameMap.IsCellMovable(dm.X, dm.Y);//проверяем можно ли передвинуть фишку по данным координатам
      MousePoint := dm;//
      PB_Screen.Repaint;//пререрисовка
    end;
  end;
end;

{функция изменения размера поля}
procedure TMForm.SetMapSizeButtonClick(Sender: TObject);
begin
  SE_MapY.Value := SE_MapX.Value;//размер поля строго квадратной формы
  GameMap.SetSize(SE_MapX.Value, SE_MapY.Value);//задание размера карты
  FlushMapButton.Click;//сбрасываем поле
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

{процедура при отпускании кнопки мыши}
procedure TMForm.PB_ScreenMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if not (bMouseCellActive and (PC_Game.ActivePageIndex = 0)) then exit;//если отпускаем мышь не на поле игры, то выходим
  GameMap.MoveCell(MousePoint.X, MousePoint.Y);//перемещение фишки по заданным координатам, которые при в
  //возникновении процедуры были переданы
  MousePoint := Point(0, 0);//обнуляем коорлинаты
  PB_ScreenMouseMove(Sender, Shift, X, Y);
  PB_Screen.Repaint;//перерисовка
end;

{процедура поиска решения методом поиска в ширину}
procedure TMForm.B_AI1StartClick(Sender: TObject);
var
  iWaypointId: integer;
  oPoint: TWaypoint;
begin
  B_AI1ClearList.Click;
  P_Process.Visible := true;
  oWideAI.Process(GameMap);//запускаем процесс поискав ширину
  //запускаем процедуру поиска маршрута решения
  if oWideAI.GetRightPass(oWideWay) then
  begin
    if oBasicMap <> nil then oBasicMap.Free;
    oBasicMap := GameMap.Peer;
    LB_AI1WayList.Clear;
    iWaypointId := 0;
    //выстраиваем списко ходов для получения выигрыша
    while iWaypointId < oWideWay.Count do
    begin
      oPoint := oWideWay.Point[iWaypointId];
      LB_AI1WayList.Items.AddObject(format('Ход [%d, %d]', [oPoint.X + 1, oPoint.Y + 1]), oPoint);
      inc(iWaypointId);
    end;
  end;
  //P_Process.Visible := false;
end;

{процедура возникает при нажатии на кнопку "Очистить"}
procedure TMForm.B_AI1ClearListClick(Sender: TObject);
begin
  //чистим списки поиска в ширину
  LB_AI1WayList.Clear;
  oWideWay.Clear;
  oWideAI.Clear;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  GameMap.ClearPeers;//очищаем копии
  oBasicMap := nil;
  PB_Screen.Repaint;//перерисовка
  if Sender = nil then exit;
  B_AI2ClearListClick(nil);
  B_AI3ClearListClick(nil);
end;

{процедура сброски - возвращает в исходную начальную разыгрываемую ситуацию}
procedure TMForm.B_AI1ResetClick(Sender: TObject);
begin
  LB_AI1WayList.Tag := -1;
  LB_AI1WayList.ItemIndex :=  -1;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);//устанавливаем начальную ситуацию, которая
  //была ранее сохранена в oBasicMap
  
  PB_Screen.Repaint;//перерисовываем
end;

{процедура нажатия на кнопку "Шаг"}
procedure TMForm.B_AI1StepClick(Sender: TObject);
var
  oPoint: TWaypoint;
begin
  if GameMap.IsValid or (1 > LB_AI1WayList.Count) then exit;//если сразу было решение при начальной раскладке, то выходим
  if LB_AI1WayList.Tag <> LB_AI1WayList.ItemIndex then B_AI1Reset.Click;//если мы щелкнули на каком-то шаге мышью, а он не
  //совпадает с реальным шагом, то сбрасываем Tag
  
  LB_AI1WayList.ItemIndex := LB_AI1WayList.ItemIndex + 1;//берем следующий шаг
  oPoint := TWaypoint(LB_AI1WayList.Items.Objects[LB_AI1WayList.ItemIndex]);//определяем шаг
  GameMap.MoveCell(oPoint.X, oPoint.Y);//выполняем перемещение фишки по заданным коорлинатам
  PB_Screen.Repaint;//перерисовываем карту игры
  LB_AI1WayList.Tag := LB_AI1WayList.ItemIndex;
end;

{процесс срабатывает при поиске в ширину}
Procedure TMForm.AI1Process(iStep: integer; iMax: integer);
begin
  L_AI1SCount.Caption := IntToStr(iStep); //выводи сообщение какой шаг
  L_AI1STotal.Caption := IntToStr(iMax);  //все множество решений игры
  Application.ProcessMessages;
end;

{процесс срабатывает при поиске в глубину}
Procedure TMForm.AI2Process(iStep: integer; iMax: integer);
begin
  L_AI2SCount.Caption := IntToStr(iStep); //выводи сообщение какой шаг
  L_AI2STotal.Caption := IntToStr(iMax);  //все множество решений игры
  Application.ProcessMessages;
end;

{процесс запуска при поиска по градиенту}
Procedure TMForm.AI3Process(iStep: integer; iMax: integer);
begin
  L_AI3SCount.Caption := IntToStr(iStep); //какой шаг по счету
  L_AI3STotal.Caption := IntToStr(iMax);  //все множество ходов
  Application.ProcessMessages;
end;


{Процедура нажатиня на кнопку "Искать" в методе по градиенту}
procedure TMForm.B_AI3StartClick(Sender: TObject);
var
  iWaypointId: integer;
  oPoint: TWaypoint;
begin
  B_AI3ClearList.Click;//очищаем список
  P_Process3.Visible := true;
  oGradientAI.Process(GameMap);//запуск процесса поиска по градиенту
  //выстравиваем маршрут решенеия, если он есть
  if oGradientAI.GetRightPass(oGradientWay) then begin
    if oBasicMap <> nil then oBasicMap.Free;
    oBasicMap := GameMap.Peer;
    LB_AI3WayList.Clear;
    iWaypointId := 0;
     //выстраиваем списко ходов для получения выигрыша, выводи их на форму
    while iWaypointId < oGradientWay.Count do begin
      oPoint := oGradientWay.Point[iWaypointId];
      LB_AI3WayList.Items.AddObject(format('Ход [%d, %d]', [oPoint.X + 1, oPoint.Y + 1]), oPoint);
      inc(iWaypointId);
    end;
  end;
  //P_Process3.Visible := false;
end;

{процедура сброски - возвращает в исходную начальную разыгрываемую ситуацию}
procedure TMForm.B_AI3ResetClick(Sender: TObject);
begin
  LB_AI3WayList.Tag := -1;
  LB_AI3WayList.ItemIndex :=  -1;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);//копируем карту
  PB_Screen.Repaint;//перерисовываем
end;


{Процедура нажатия на кнопку "Шаг" }
procedure TMForm.B_AI3StepClick(Sender: TObject);
var
  oPoint: TWaypoint;
begin
  if GameMap.IsValid or (1 > LB_AI1WayList.Count) then exit;
  if LB_AI3WayList.Tag <> LB_AI3WayList.ItemIndex then B_AI3Reset.Click;
  LB_AI3WayList.ItemIndex := LB_AI3WayList.ItemIndex + 1;//переходи на следующий шаг
  oPoint := TWaypoint(LB_AI3WayList.Items.Objects[LB_AI3WayList.ItemIndex]);//берем координаты хода
  GameMap.MoveCell(oPoint.X, oPoint.Y);//перемещение фишки по заданным координатам
  PB_Screen.Repaint;//перерисовываем
  LB_AI3WayList.Tag := LB_AI3WayList.ItemIndex;
end;

{Процедура при нажатии на кнопку "Очистить"}
procedure TMForm.B_AI3ClearListClick(Sender: TObject);
begin
//очищаем списки решений при поиске по градиенту
  LB_AI3WayList.Clear;
  oWideWay.Clear;
  oWideAI.Clear;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  GameMap.ClearPeers;
  oBasicMap := nil;
  PB_Screen.Repaint;//перерисовываем
  if Sender = nil then exit;
  B_AI1ClearListClick(nil);
  B_AI2ClearListClick(nil);
end;

procedure TMForm.B_AI2StartClick(Sender: TObject);
var
  iWaypointId: integer;
  oPoint: TWaypoint;
begin
  B_AI2ClearList.Click;
  P_Process2.Visible := true;
  oDeepAI.Process(GameMap);//запускаем процесс поискав ширину
  //запускаем процедуру поиска маршрута решения
  if oDeepAI.GetRightPass(oDeepWay) then
  begin
    if oBasicMap <> nil then oBasicMap.Free;
    oBasicMap := GameMap.Peer;
    LB_AI2WayList.Clear;
    iWaypointId := 0;
    //выстраиваем списко ходов для получения выигрыша
    while iWaypointId < oDeepWay.Count do
    begin
      oPoint := oDeepWay.Point[iWaypointId];
      LB_AI2WayList.Items.AddObject(format('Ход [%d, %d]', [oPoint.X + 1, oPoint.Y + 1]), oPoint);
      inc(iWaypointId);
    end;
  end;
  //P_Process.Visible := false;
end;

procedure TMForm.B_AI2ResetClick(Sender: TObject);
begin
  LB_AI2WayList.Tag := -1;
  LB_AI2WayList.ItemIndex :=  -1;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);//устанавливаем начальную ситуацию, которая
  //была ранее сохранена в oBasicMap

  PB_Screen.Repaint;//перерисовываем
end;

procedure TMForm.B_AI2StepClick(Sender: TObject);
var
  oPoint: TWaypoint;
begin
  if GameMap.IsValid or (1 > LB_AI2WayList.Count) then exit;//если сразу было решение при начальной раскладке, то выходим
  if LB_AI2WayList.Tag <> LB_AI2WayList.ItemIndex then B_AI2Reset.Click;//если мы щелкнули на каком-то шаге мышью, а он не
  //совпадает с реальным шагом, то сбрасываем Tag
  
  LB_AI2WayList.ItemIndex := LB_AI2WayList.ItemIndex + 1;//берем следующий шаг
  oPoint := TWaypoint(LB_AI2WayList.Items.Objects[LB_AI2WayList.ItemIndex]);//определяем шаг
  GameMap.MoveCell(oPoint.X, oPoint.Y);//выполняем перемещение фишки по заданным коорлинатам
  PB_Screen.Repaint;//перерисовываем карту игры
  LB_AI2WayList.Tag := LB_AI2WayList.ItemIndex;
end;

procedure TMForm.B_AI2ClearListClick(Sender: TObject);
begin
  //чистим списки поиска в ширину
  LB_AI2WayList.Clear;
  oDeepWay.Clear;
  oDeepAI.Clear;
  if oBasicMap <> nil then GameMap.Assign(oBasicMap);
  GameMap.ClearPeers;//очищаем копии
  oBasicMap := nil;
  PB_Screen.Repaint;//перерисовка
  if Sender = nil then exit;
  B_AI1ClearListClick(nil);
  B_AI3ClearListClick(nil);
end;

end.
