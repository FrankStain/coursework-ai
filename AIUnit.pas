unit AIUnit;

interface

uses
  Windows, Classes, SysUtils, MapUnit;

Type
  //объектный тип - делегирование
  //переменной такого типа можно присвоить указатель на метод  класса
  //TOnProcessEvent - название типа
  //важно, чтобы медот имел два параметра типа integer
  TOnProcessEvent = Procedure (iStep: integer; iMax: integer) of object;

  (**
   * Элемент дерева вариантов.
   * Служит для создания структуры квадратичного дерева (с четырьмя отростками).
   *
   * Терминология:
   *   Дерево - рекурсивная структура данных, в которой элементы связаны по принципу "родитель - несколько потомков"
   *   Корень дерева - элемент дерева, не имеющий родительского элемента
   *   Отросток элемента - элемент, являющийся потомком другого элемента
   *   Корень элемента - непосредственный родитель элемента дерева
   *
   * Каждый отросток этого элемента станет некоторого рода вариантом этого элемента.
   * Изначально, отросток будет представлять из себя полную копию самого элемента.
   * Будучи копией, отросток не будет содержать ни одного адреса данных своего корня, соответствие
   * копии будет только на уровне данных, но не на уровне их адресов.
   * А когда в отростке, согласно варианту, будет совершен ход, отросток из копии станет
   * вариантом элемента, т.к. утратит свойства копии.
   *
   *)
  TMapTree = class
    Protected
      // Вес элемента, число ходов, с сего момента оставшихся до выигрыша
      FWeight: integer;
      // Карта, содержит уникальное состояние поля, сама по себе карта является состоянием элемента
      FMap: TMap;
      // Указатель на родительский элемент, на корень данного элемента, у корня дерева там будет лежать nil
      FParent: TMapTree;
      // Набор указателей на отростки элемента, в каждой ячейке nil или указатель на отросток
      FBranches: array[0..3] of TMapTree;

      // Конструктор копирования, фактически он создаст элемент-копию, который сразу же станет отростком oParent
      Constructor Create(oParent: TMapTree); overload;

      // Инициализация полей элемента
      Procedure init;
      // Добавление элемента в список отростков
      Procedure AddBranch(oValue: TMapTree);
      // Удаление элемента из списка отростков
      Procedure DeleteBranch(oValue: TMapTree);

      // Возвращает отросток по его индексу
      Function GetBranch(index: integer): TMapTree;
      // Возвращает глубину элемента относительно корня дерева
      Function GetDepth: integer;

    Public
      Constructor Create(oMap: TMap); overload;
      Destructor Destroy; override;

      // Создает и возвращает отросток дерева
      Function MakeBranch: TMapTree; virtual;
      // Очищает, удаляя и сами объекты, список отростков
      Procedure ClearBranches;
      // Помечает элемент, состояние которого свидетельствует о достижении цели
      Procedure MarkAsComplited;
      // Проверяет, не эквивалентно ли состояние элемента состоянию параметра
      Function IsMapsEqual(oMap: TMapTree): boolean;

      // Корень элемента
      Property Root: TMapTree read FParent;
      // Карта (состояние) элемента
      Property Map: TMap read FMap;
      // Отросток по индексу
      Property Branch[index: integer]: TMapTree read GetBranch;
      // Вес элемента
      Property Weight: integer read FWeight;
      // Глубина элемента
      Property Depth: integer read GetDepth;
  end;

  (**
   * Список для хранения элементов дерева, вспомогательная структура.
   * Необходим для хранения и обработки элементов дерева в строго заданном порядке.
   * Применяется в алгоритмах поиска. Имеет FIFO и LIFO механизмы укладки элементов.
   * Доступ к обоим механизмам синхронный, т.е. уложить элементы можно в стиле FIFO,
   * а доставать - по принципам LIFO.
   *
   * Под элементом, в рамках данного класса и всех наследников, подразумивается указатель
   * на элемент дерева вариантов.
   *)
  TMapList = class
    Private
      // Сам по себе список указателей, все элементы хранятся в нем
      FList: TList;

    Protected
      // Возвращает число элементов в списке
      Function GetCount: integer;
      // Возвращает элемент по его индексу
      Function GetItem(iId: integer): TMapTree;

    Public
      Constructor Create;
      Destructor Destroy; override;

      // FIFO: добавляет элемент в список по принципу очереди
      Procedure Send(oMap: TMapTree); virtual;
      // LIFO: добавляет элемент в список по принципу стека
      Procedure Push(oMap: TMapTree); virtual;
      // FIFO & LIFO: изымает элемент из списка и возвращает в качестве результата
      Function Recv: TMapTree;
      // Очищает список элементов
      Procedure Clear;

      // Число элементов списка
      Property Count: integer read GetCount;
      // Доступ к элементу по индексу
      Property Item[index: integer]: TMapTree read GetItem;
  end;

  // Предекларирование, определние списка ходов будет ниже
  TWaypointList = class;

  (**
   * Точка маршрута, иными словами - ход.
   * Используется для инкапсуляции пары координат хода и наделения их функциями автоматизации.
   * Семантически, ход содержит координаты фишки, которую необходимо будет передвинуть
   *)
  TWaypoint = class
    Private
      // Родительский список ходов, предекларирование было необходимло именно для этого объявления
      FList: TWaypointList;
      // Пара, координаты хода
      FX: integer;
      FY: integer;

    Public
      Constructor Create(X, Y: integer; oList: TWaypointList);
      Destructor Destroy; override;

      // Свойства только для чтения, служат для доступа к значениям хода
      Property X: integer read FX;
      Property Y: integer read FY;
      Property Parent: TWaypointList read FList;
  end;

  (**
   * Список ходов. Добавление ходов организовано по принципу FIFO.
   * Используется как контейнер для размещения самих ходов.
   *
   * Под ходом, в рамках данного класса, будет подразумиваться указатель на объект класса TWaypoint
   *)
  TWaypointList = class
    Private
      // Список, в котором и будут храниться ходы
      FList: TList;

    Protected
      // Добавление хода в список
      Procedure AddPoint(oPoint: TWaypoint);
      // Удаление хода из списка, только изъятие из списка, без удаления объекта хода
      Procedure DeletePoint(oPoint: TWaypoint);

      // Получение количества ходов
      Function GetCount: integer;
      // Получение необходимого хода по его индексу
      Function GetPoint(iId: integer): TWaypoint;

    Public
      Constructor Create;
      Destructor Destroy; override;

      // Добавление хода по его паре координат
      Function Add(X, Y: integer): TWaypoint;
      // Удаление хода по его фактическому адресу
      Procedure Delete(var oPoint: TWaypoint); overload;
      // Удаление хода по его индексу
      Procedure Delete(iId: integer); overload;
      // Очистка списка ходов
      Procedure Clear;

      // Только для чтения, возвращает количество ходов в списке
      Property Count: integer read GetCount;
      // Только для чтения, возвращает необходимый ход по его индексу
      Property Point[index: integer]: TWaypoint read GetPoint;
  end;

  (**
   * Класс реализации алгоритма поиска "в ширину".
   *
   * Для своей работы использует объекты классов TMapTree и TMapList.
   * Дерево вариантов строится на основе элементов класса TMapTree. Для хранения очереди
   * исследуемых элементов используется класс TMapList и его интерфейс FIFO-обращений.
   * Метод ведет проверку элементов на повторение, для этого так же используется TMapList,
   * в котором хранятся только элементы с уникальными состояниями.  
   *)
  TWidewayAI = class
    Private
      // Корень дерева вариантов
      FRoot: TMapTree;
      // FIFO-список исследуемых элементов
      FPipe: TMapList;
      // FIFO-список уникальных элементов
      FCheckList: TMapList;
      // Событие, сигнализирующее о ходе процесса
      FOnProcess: TOnProcessEvent;
      // Максимальное число вариантов
      FComplexity: integer;

    Protected
      // Тело алгоритма поиска
      Function FindWay: boolean; virtual;
      // Обертка для вызова FOnProcess
      Procedure ProcessEvent(iStep: integer; iMax: integer);

    Public
      Constructor Create;
      Destructor Destroy; override;

      // Очищает дерево вариантов, удаляет списки, чистит всю динамичискую память
      Procedure Clear;
      // Запускает алгоритм поиска
      Function Process(oInitialMap: TMap): boolean; virtual;
      // Выбирает из дерева вариантов оптимальный путь
      Function GetRightPass(oWay: TWaypointList): boolean;

      // Корень дерева, свойство только для чтения
      Property Root: TMapTree read FRoot;
      // Указатель на событие сигнала о ходе процесса
      Property OnProcess: TOnProcessEvent read FOnProcess write FOnProcess;
  end;

  (**
   * Элемент дерева с эвристическим весом. Наследует все свойства от TMapTree.
   * Класс используется при реализации алгоритма поиска по градиенту.
   *
   * Элемент наделен эвристическим весом, который, в идеале, показывает примерное количество ходов,
   * оставшихся до выигрыша, расстояние до цели, другими словами.
   *)
  TMapEuristicTree = class(TMapTree)
    Protected
      // Эвристический вес
      FCompleteness: integer;

      // Подсчет эвристического веса для одной фишки по ее координатам
      Function GetPointCompliteness(X, Y: integer): integer;

    Public
      // Корректирует эвристический вес элемента
      Procedure FixCompletenessLevel;
      // Создает отросток дерева эвристических элементов
      Function MakeBranch: TMapTree; override;

      // Только для чтения, эвристический вес элемента
      Property Completeness: integer read FCompleteness;
  end;

  (**
   * Список с упорядочиванием при вставке. Наследует все совйства от класса TMapList.
   * Для работы списка используются элементы с эвристикой, сортировка элементов производится
   * по возврастанию эвристического веса, с использованием алгоритма половинного сечения.
   *)
  TMapEuristicList = class(TMapList)
    Protected
      // Размещает элемент, попутно подбирая ему подходящее место, не нарушающее общей упорядоченности
      Function PlaceItem(oNode: TMapEuristicTree; iLeftMargin, iRightMargin: integer): boolean;

    Public
      // Общий интерфейс добавления элемента в список
      Procedure Send(oMap: TMapTree); override;
  end;

  (**
   * Класс реализации алгоритма поиска "по градиенту". Полностью наследует свойства алгоритма поиска в ширину.
   *
   * Для своей работы использует классы TMapEuristicTree, для организации эвристического дерева
   * вариантов, и TMapEuristicList, для организации эвристики поиска.
   * Алгоритм
   *
   * Список TMapEuristicList выстраивает элементы в своей очереди так, что самыми первыми из списка
   * будут доставаться элементы с наименьшим эвристическим весом.
   * Если, в это же время, эвристический вес каждого элемента расчитывать как кратчайшее расстояние
   * до цели, то список ближе всего к выходу всегда будет содержать самые близкие к цели элементы.
   * Таким образом, теоритически, метод должен быть более скорым на оптимальное решение.
   * Но на практике точно расчитать число ходов на поле, оставшихся до выигрыша, почти не
   * представляется возможным.
   *)
  TGradientAI = class(TWidewayAI)
    Public
      // Запускает алгоритм поиска по градиенту
      Function Process(oInitialMap: TMap): boolean; override;
  end;

  (**
   * Класс реализации алгоритма поиска "в глубину". Наследует свойства от класса поискав ширину.
   *
   * В основном, алгоритм использует все те же поля, что и алгоритм поиска в ширину.
   * Запуск поиска отличается лишь тем, что для поиска в глубину сперва расчитывается максимальная
   * глубина рекурсии.
   *
   * Глубина рекурсии определяется относительно числа фишек на поле. Чтоб переместить 1 фишку на
   * занятое поле, нужно сперва это поле освободить, для этого может понадобиться максимум 3 хода.
   * То есть, для перемещения 1 фишки на занятую клетку, нужно затратить 4 хода. Если фишек на поле
   * 8, то для того, чтоб каждую фишку переместить на уже занятую клетку, понадобится 8*4 = 32 хода.
   * При глубине в 32 хода можно практически гарантировать нахождение решения для поля 3*3.
   *)
  TDeepwayAI = class(TWidewayAI)
    Protected
      // Максимальная глубина рекурсии
      FMaxDeepLevel: integer;

      // Рекурсивная функция, тело алгоритма поиска
      Function FindWay: boolean; override;

    Public
      // Запускает алгоритм поиска в глубину
      Function Process(oInitialMap: TMap): boolean; override;
      
  end;

implementation

uses Types;

{**
 * Функция определяет все множество ходов
 * в реалии подсчитывает факториал
 * (для игры в 9, возможно 9! ходов)                                
 *}
function fact(X: integer): integer;
begin
  Result := X;
  while X > 2 do begin
    dec(X);
    Result := Result * X;
  end;
end;

(**
 * Конструтокр создания дерева
 *
 *
 *)
Constructor TMapTree.Create(oParent: TMapTree);
begin
  Inherited Create;//вызов родительского метода конструктора
  init;//инициализация полей
  FParent := oParent;
  FParent.AddBranch(self);//добавление элемента в список отростков
  FMap := FParent.FMap.Peer;//добавление элемента в список копий
end;

Constructor TMapTree.Create(oMap: TMap);
begin
  Inherited Create;
  init;
  FMap := oMap;
end;


{**
* Инициализация полей элемента
*
*}
Procedure TMapTree.init;
begin
  //FBrunches содержит указатели на 4 отростка от дерева
  FillChar(FBranches, sizeof(FBranches), 0); //заполнение копий нулями
  FParent := nil;
  FMap := nil;
end;

Destructor TMapTree.Destroy;
begin
  ClearBranches;
  if FParent <> nil then begin
    FMap.Free;
    FParent.DeleteBranch(self);
  end;
  inherited;
end;

{**
* Процедура добавление элемента в список отростоков
* добавляет элемент в конец списка, iBranchId увеличивается
* пока не встретится указатель на пустую клетку
*}
Procedure TMapTree.AddBranch(oValue: TMapTree);
var
  iBranchId: integer;
begin
  if FBranches[3] = nil then
  begin
    iBranchId := 0;
    while (3 >= iBranchId) and (nil <> FBranches[iBranchId]) do inc(iBranchId);
    FBranches[iBranchId] := oValue;
  end;
end;

{**
* Процедура удаления элемента из списка отростков
* происходит переприсваивание (смещение) на один элемент левее
* последний элемент указывает на nil
*}
Procedure TMapTree.DeleteBranch(oValue: TMapTree);
var
  iBranchId: integer;
begin
  iBranchId := 0;
  while (3 >= iBranchId) and (oValue <> FBranches[iBranchId]) do inc(iBranchId);
  if iBranchId > 3 then exit;
  while 3 > iBranchId do
  begin
    FBranches[iBranchId] := FBranches[iBranchId + 1];
    inc(iBranchId);
  end;
  FBranches[3] := nil;
end;

(**
 * Создает отросток элемента.
 * Всего таких отростков может быть только 4.
 *
 * Возвращаемое значение:
 *   Возвращает объект Элемента дерева, являющийся отростком и полной копией самого элемента.
 *   Если у элемента уже есть 4 отростка, метод вернет nil.
 *)
Function TMapTree.MakeBranch: TMapTree;
begin
  if FBranches[3] <> nil then Result := nil
  else Result := TMapTree.Create(self);
end;


{**
 * Процедура определения длины решения
 * идем снизу вверх, цепляя порождающую вершину
 * при заходе в цикл мы уже как бы имеем один шаг для корня
 *}
Procedure TMapTree.MarkAsComplited;
var
  oRoot: TMapTree;
  iWeight: integer;
begin
  FWeight := 1;//вес врешины
  oRoot := FParent;
  iWeight := 2;//
  while oRoot <> nil do begin
    if (oRoot.FWeight > 0) and (oRoot.FWeight < iWeight) then break;//если вершина уже имеет вес и он
    //меньше , чем тот что мы задаем то выходим отсюда
    oRoot.FWeight := iWeight;
    inc(iWeight);
    oRoot := oRoot.Root;
  end;
end;


{**
 * Функция проверки на уникальность данной раскладки поля
 * т.е. если такое поелу уже встретилось, то функция вернет true
 * значит такое повторное поле обрабатывать не стоит
 * FMap - поле в чек-таблице с переданным номером
 *
 * Параметры:
 *   oMap - поле с возможно осуществимым ходом
 *}
Function TMapTree.IsMapsEqual(oMap: TMapTree): boolean;
var
  x: integer;
  y: integer;
begin
  Result := true;
  y := 0;
  while (y < FMap.Height) and Result do begin
    x := 0;
    while (x < FMap.Width) and Result do begin
      Result := FMap.Cell[x, y] = oMap.Map.Cell[x, y];
      inc(x);
    end;
    inc(y);
  end;
end;

{**
* Процедура очистки самих отростков
*
*}
Procedure TMapTree.ClearBranches;
var
  iBranchId: integer;
begin
  iBranchId := 0;
  while 4 > iBranchId do begin
    if FBranches[iBranchId] <> nil then begin
      FBranches[iBranchId].Free;
      FBranches[iBranchId] := nil;
    end;
    inc(iBranchId);
  end;
end;

{**
* Функция возвращает отросток по его индексу
*
*}
Function TMapTree.GetBranch(index: integer): TMapTree;
begin
  Result := nil;
  if (0 > index) or (3 < index) then exit;
  Result := FBranches[index];
end;

{**
 * Функция возвращает глубину текущей вершины относительно корня всего деревa
 *}
Function TMapTree.GetDepth: integer;
var
  oRoot: TMapTree;
begin
  Result := 1;
  oRoot := FParent;
  while oRoot <> nil do
  begin
    inc(Result);
    oRoot := oRoot.Root;
  end;
end;

{**
* Конструктор создания списка, в котром хранятся элементы дерева
*}
Constructor TMapList.Create;
begin
  FList := TList.Create;
end;

Destructor TMapList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

{**
 * Реализация FIFO-принципа добавления элемента, добавляет элемент в конец списка
 *
 * Параметры:
 *   oMap - Элемент, который необходимо добавить в список
 *}
Procedure TMapList.Send(oMap: TMapTree);
begin
  FList.Add(oMap);
end;

(**
 * Реализация LIFO-принципа добавления элемента, добавляет элемент к началу списка
 *
 * Параметры:
 *   oMap - Элемент, который необходимо добавить в список
 *
 *)
Procedure TMapList.Push(oMap: TMapTree);
begin
  FList.Insert(0, oMap);
end;

(**
 * Функция изъятия элемента из очереди
 * попутно элемент из очереди удаляет
 *
 * возвращаемое значение:
 *   возвращает объект Элемента дерева.
 *   если элементов больше нет в очереди, метод вернет nil.
 *)
Function TMapList.Recv: TMapTree;
begin
  Result := nil;
  if FList.Count < 1 then exit;
  //Извлекаем элемент из начала очереди
  Result := TMapTree(FList.Items[0]);
  //Удаляем извлемент
  FList.Delete(0);
end;

{**
* Процедура очистки списка элементов
*}
Procedure TMapList.Clear;
begin
  while FList.Count > 0 do FList.Delete(0);
end;


(**
 * Функция определяет количество элементов в списке
 *
 * Возвращаемое значение:
 *   Число элементов в списке
 *)
Function TMapList.GetCount: integer;
begin
  Result := FList.Count;
end;

{**
* Функция возвращает элемент по его индексу
*
*}
Function TMapList.GetItem(iId: integer): TMapTree;
begin
  Result := nil;
  if (0 > iId) or (FList.Count <= iId) then exit;
  Result := TMapTree(FList.Items[iId]);
end;

{**
* Конструктор при создании точек маршрута
*
*}
Constructor TWaypoint.Create(X, Y: integer; oList: TWaypointList);
begin
  inherited Create;//вызов родительского метода конструктора
  FX := X;//устанавливаем координату по оси X
  FY := Y;//устанавливаем координату по оси Y
  FList := oList;
  FList.AddPoint(self);//добавление хода в список
end;

Destructor TWaypoint.Destroy;
begin
  FList.DeletePoint(self);
  inherited;
end;

{**
* Конструктор при создании списка ходов
*}
Constructor TWaypointList.Create; 
begin
  inherited;
  FList := TList.Create;
end;

Destructor TWaypointList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

{**
* Функция добавления хода в список ходов по заданным координатам
*}
Function TWaypointList.Add(X, Y: integer): TWaypoint;
begin
  Result := TWaypoint.Create(X, Y, self);
end;

{**
* Процедура удаления индекса по его фактическому адресу
*}
Procedure TWaypointList.Delete(var oPoint: TWaypoint);
begin
  oPoint.Free;
  oPoint := nil;
end;

{**
* Удаление хода по его индексу
*}
Procedure TWaypointList.Delete(iId: integer);
var
  oPoint: TWaypoint;
begin
  oPoint := TWaypoint(FList.Items[iId]);
  Delete(oPoint);
end;

{**
* Процедура очистки списка ходов
*}
Procedure TWaypointList.Clear;   
begin
  while FList.Count > 0 do TWaypoint(FList.Items[0]).Free;
end;

{**
* Процедура добавления хода в список ходов
*}
procedure TWaypointList.AddPoint(oPoint: TWaypoint);
begin
  FList.Add(oPoint);
end;

{**
* Процедура удаления хода из списка ходов
* объект хода не удаляется
*}
Procedure TWaypointList.DeletePoint(oPoint: TWaypoint);
begin
  FList.Remove(oPoint);
end;

{**
* Функция возвращает количество ходов в списке ходов
*}
Function TWaypointList.GetCount: integer; 
begin
  Result := FList.Count;
end;

{**
* Функция возвращает ход по его индексу
* iId - индекс по которому нужно определить поле
*}
Function TWaypointList.GetPoint(iId: integer): TWaypoint;
begin
  Result := nil;
  if (0 > iId) or (FList.Count <= iId) then exit;
  Result := TWaypoint(FList.Items[iId]);
end;

Constructor TWidewayAI.Create;
begin
  inherited;
  FRoot := nil;
  FPipe := nil;
  FCheckList := nil;
end;

Destructor TWidewayAI.Destroy;
begin
  Clear;
  inherited;
end;

(**
 * Метод для запуска алгоритма поиска  в ширину
 *
 * Параметры:
 *   oInitialMap - изначальная карта, относительно которой нужно найти решение
 *
 * Возвращаемое значение:
 *   Возвращает true тогда, когда алгоритм смог найти хотя бы одно решение
 *
 *)
Function TWidewayAI.Process(oInitialMap: TMap): boolean;
begin
  // Сперва очистка списков и инициализация объектов алгоритма
  if FRoot <> nil then Clear;
  // В дереве вариантов будем использовать элементы дерева
  FRoot := TMapTree.Create(oInitialMap);
  //Создаем обычную очедерь - по правилу FIFO
  FPipe := TMapList.Create;
  //Создаем чек-таблицу, хранящую по одному экземпляру состоняия поля
  FCheckList := TMapList.Create;
  //Кладем в очередь вариантов корень всего дерева - элемент с изначальной картой (Send-виртуальный)
  FPipe.Send(FRoot);
  // Его же, за его уникальность, сразу же кладем в очередь уникальных вариантов
  FCheckList.Send(FRoot);
  //Считаем количество всех возможных вариантов состояния поля...
  FComplexity := fact(oInitialMap.Width * oInitialMap.Height);
  //Запускаем алгоритм поиска в ширину
  Result := FindWay;
end;


{реализация метода поиска в ширину}
Function TWidewayAI.FindWay: boolean;
var
  oCurMap: TMapTree;     //текущее рассматриваемое поле
  oNewMap: TMapTree;     //новое поле для совершения хода
  ptCenter: TPoint;
  ptRootCenter: TPoint;
  ptWalk: TPoint;        //координаты возможно осуществляемого хода
  iStepId: integer;
  iCheckListId: integer;
begin
  Result := false;
  {заходим в цикл поиска пока в очереди хоть что-то есть}
  while FPipe.Count > 0 do begin
    oCurMap := FPipe.Recv; //вытаскиваем поле из очереди, попутно его удаляя
    ptCenter := oCurMap.Map.GetEmptyCell;//определение пустой клетки
    {относительно пустой клетки можно сделать только 4 хода - max}
    for iStepId := 0 to 3 do begin
      with ptWalk do begin
        X := ptCenter.X + arMoveDirections[iStepId, 0];
        Y := ptCenter.Y + arMoveDirections[iStepId, 1];
      end;
      //если такой ход сделать нельзя то идем на следующий шаг цикла
      if not oCurMap.Map.IsCellMovable(ptWalk.X, ptWalk.Y) then continue;
      //делаем проверку не повторяет ли этот ход предыдущий:
      //проверка делается пог местоположению пустой клетки
      if oCurMap.Root <> nil then begin
        ptRootCenter := oCurMap.Root.Map.GetEmptyCell;//определяем координаты пустой клетки текущего поля
        //если ход равен предыдущему, то на следующий шаг цикла
        if (ptRootCenter.X = ptWalk.X) and (ptRootCenter.Y = ptWalk.Y) then continue;
      end;
       //создаем копию
      oNewMap := oCurMap.MakeBranch;
      //если ранее решение уже было найдено, и его глуьина меньше, то на следующий ход идем
      if (FRoot.Weight > 0) and (FRoot.Weight < oNewMap.Depth) then continue;
      //делаем ход в копии
      oNewMap.Map.MoveCell(ptWalk.X, ptWalk.Y);
      //если нашли решение,то помечаем лист как выигрыш
      if oNewMap.Map.IsValid then begin
       //расчитываем вес решения
        oNewMap.MarkAsComplited;
        Result := true;
      end else begin
        iCheckListId := FCheckList.Count;
        while iCheckListId > 0  do begin
          dec(iCheckListId);
          if FCheckList.Item[iCheckListId].IsMapsEqual(oNewMap) then break;
        end;
        if iCheckListId = 0 then begin
          FCheckList.Send(oNewMap);//добавление поля в чек-таблицу, чтобы потом обработанное поле еще раз не добавлять в очередь
          FPipe.Send(oNewMap);//добавляем поле в очередь
        end;
      end;
      ProcessEvent(FCheckList.Count, FComplexity);
    end;
  end;
end;

Procedure TWidewayAI.ProcessEvent(iStep: integer; iMax: integer);
begin
  if not assigned(FOnProcess) then exit;//если в классе не задано событие отклика, то и вызывать его не надо
  FOnProcess(iStep, iMax);
end;

{функция построения выигрвшного маршрута
в реалии у нас записаны коорлинаты пустых клеток каждого хода}
Function TWidewayAI.GetRightPass(oWay: TWaypointList): boolean;
var
  oNode: TMapTree;
  iBranchId: integer;
  iWayBranch: integer;
  iWayWeight: integer;
  ptWaypoint: TPoint;
begin
  Result := false;
  oWay.Clear;
  if FRoot = nil then exit;
  oNode := FRoot;

  while not ((oNode = nil) or Result) do begin
    if oNode.Weight = 0 then break;
    iWayWeight := 0;
    iWayBranch := 0;
     {определение хода с наименьшим весом, чтобы построить наилучший результат}
    for iBranchId := 0 to 3 do begin
      if oNode.Branch[iBranchId] = nil then continue;
      if (iWayWeight = 0) or (oNode.Branch[iBranchId].Weight < iWayWeight) then begin
        if oNode.Branch[iBranchId].Weight = 0 then continue;
        iWayWeight := oNode.Branch[iBranchId].Weight;
        iWayBranch := iBranchId;//номер хода (нумерация с 0 до 3)
      end;
    end;
    if iWayWeight > 0 then begin
      ptWaypoint := oNode.Branch[iWayBranch].Map.GetEmptyCell;//координаты пустой клетки выбранного шага
      //по отношению к прошлым координатам пустой клетки и координатам текущей пустой клетки легко определеить координаты хода
      
      oWay.Add(ptWaypoint.X, ptWaypoint.Y);//добавление хода
      oNode := oNode.Branch[iWayBranch];//делаем выбранный ход текущей вершиной для построение дальнейшего маршрута
      Result := oNode.Weight = 1;//если вес вершины один, то конец оптимальнго пути
    end else oNode := nil;
  end;
end;

Procedure TWidewayAI.Clear;
begin
  if FPipe <> nil then FPipe.Clear;
  FPipe.Free;
  if FCheckList <> nil then FCheckList.Clear;
  FCheckList.Free;
  if FRoot <> nil then FRoot.Free;
  FRoot := nil;
  FPipe := nil;
  FCheckList := nil;
end;

{функция возврата веса для фишки в определнной ячейке
здесь считается для каждой фишки сколько элементов далее в поле меньшее ее}
Function TMapEuristicTree.GetPointCompliteness(X, Y: integer): integer;
var
  ActualX: integer;
  ActualY: integer;
  BaseValue: integer;
begin
  Result := 0;
  BaseValue := FMap.Cell[X, Y];
  if BaseValue = 0 then exit;

  ActualX := X;
  ActualY := Y;
  inc(ActualX);
  while ActualY < FMap.Height do begin
    while ActualX < FMap.Width do begin
      if (FMap.Cell[ActualX, ActualY] <> 0) and (FMap.Cell[ActualX, ActualY] < BaseValue) then inc(Result);
      inc(ActualX);
    end;
    ActualX := 0;
    inc(ActualY);
  end;
end;

{расчет N - формула тупика
поле FComplitenes - хранит вес хода}
Procedure TMapEuristicTree.FixCompletenessLevel;
var
  ActualX: integer;
  ActualY: integer;
begin
  FCompleteness := 0; //FMap.GetEmptyCell.Y + 1;
  ActualY := 0;
  while ActualY < FMap.Height do begin
    ActualX := 0;
    while ActualX < FMap.Width do begin
      inc(FCompleteness, GetPointCompliteness(ActualX, ActualY));
      inc(ActualX);
    end;
    inc(ActualY);
  end;
  //FCompleteness := FCompleteness + Depth;
end;

(**
 * Создает отросток элемента.
 * Всего таких отростков может быть только 4.
 *
 * Возвращаемое значение:
 *   Возвращает объект Элемента дерева, являющийся отростком и полной копией самого элемента.
 *   Если у элемента уже есть 4 отростка, метод вернет nil.
 *)
Function TMapEuristicTree.MakeBranch: TMapTree;
begin
  if FBranches[3] <> nil then Result := nil
  else Result := TMapEuristicTree.Create(self);
end;

(**
 * Метод добавления элемента в список.
 * Реализует добавление элемента в упорядоченный список
 *
 * Параметры:
 *   oMap - Элемент, который необходимо разместить в очереди
 *
 *)
Procedure TMapEuristicList.Send(oMap: TMapTree);
begin
  // Если класс добавляемого объекта не унаследован от TMapEuristicTree, то метод придется завершить.
  if not (oMap is TMapEuristicTree) then exit;
  // Сперва нужно пересчитать вес элемента
  TMapEuristicTree(oMap).FixCompletenessLevel;
  // А затем - попробовать разместить его в списке
  if not PlaceItem(TMapEuristicTree(oMap), 0, FList.Count - 1) then inherited Send(oMap);
end;

(**
 * Метод размещения элемента в очереди с сортировкой.
 *   Сортировка элементов производится прямо при добавлении.
 *   Для поиска подходящей позиции элемента используется метод половинного делеиня
 *
 * Параметры:
 *   oNode        - элемент, который необходимо добавить в само рассматриваемое множество
 *   iLeftMargin  - индекс крайнего левого элемента из рассматриваемого диапазона
 *   iRightMargin - индекс крайнего правого элемента из рассматриваемого диапазона
 *
 * Возвращаемое значение:
 *   Возвращает true только тогда, когда элемент oNode удачно размещен в списке
 *)
Function TMapEuristicList.PlaceItem(oNode: TMapEuristicTree; iLeftMargin, iRightMargin: integer): boolean;
var
  oLeftNode: TMapEuristicTree;   // Крайний левый элемент диапазона
  oRightNode: TMapEuristicTree;  // Крайний правый элемент диапазона
  oMidNode: TMapEuristicTree;    // "Медианный", средний элемент из диапазона
  iMidMargin: integer;           // "Медиана диапазона", индекс среднего элемента диапазона
begin
  // Инициализация отрицательного результата, чтоб потом просто exit вызывать
  Result := false;

  // Если указаны неправильные границы диапазона, то выходим с плохим результатом
  if iRightMargin < iLeftMargin then exit;

  // Определяем крайний левый элемент диапазона
  oLeftNode  := TMapEuristicTree(FList.Items[iLeftMargin]);
  // Если диапазон состоит только из одного элемента, то рассматриваем просто частную ситуацию
  if iRightMargin = iLeftMargin then begin
    // Если новый элемент весит больше имеющегося, то увеличиваем индекс вставки
    if oNode.Completeness > oLeftNode.Completeness then inc(iLeftMargin);
    // Вставляем элемент в список
    FList.Insert(iLeftMargin, oNode);

    Result := true;
    exit;
  end;

  // если вес нового элмента меньше или равен весу левого элемента диапазона, то его поле левее
  if oNode.Completeness <= oLeftNode.Completeness then begin
    FList.Insert(iLeftMargin, oNode);
    Result := true;
    exit;
  end;

  // Определяем крайний правый элемент диапазона
  oRightNode := TMapEuristicTree(FList.Items[iRightMargin]);//правый элемент из диапазона
  // если новое поле >= правого элемента диапазона
  if oNode.Completeness >= oRightNode.Completeness then begin
    FList.Insert(iRightMargin + 1, oNode);//новое поле добавляем правее последнего элемента
    Result := true;
    exit;
  end;
  
  // если новое поле весит больше левой границы и меньше правой, то нужно его вставить между
  iMidMargin := (iRightMargin - iLeftMargin) div 2;//делим отрезок на два
  if iMidMargin = 0 then iMidMargin := 1;
  inc(iMidMargin, iLeftMargin);

  oMidNode := TMapEuristicTree(FList.Items[iLeftMargin]);//выбираем элемент с номером iMidMargin
  // если вес того, что хотим вставить >  вес элемента с номером
  if oNode.Completeness > oMidNode.Completeness then
  // iMidMargin вызываем метод с координатами : серединной и правой
    Result := PlaceItem(oNode, iMidMargin, iRightMargin)
  else
  // вызываем метод с координатами: левой границы и серединной
    Result := PlaceItem(oNode, iLeftMargin, iMidMargin);
end;

(**
 * Метод для запуска алгоритма поиска по градиенту
 *
 * Параметры:
 *   oInitialMap - изначальная карта, относительно которой нужно найти решение
 *
 * Возвращаемое значение:
 *   Возвращает true тогда, когда алгоритм смог найти хотя бы одно решение
 *
 *)
Function TGradientAI.Process(oInitialMap: TMap): boolean;
begin
  // Сперва очистка списков и инициализация объектов алгоритма
  if FRoot <> nil then Clear;
  // В дереве вариантов будем использовать элементы дерева с подсчетом веса
  FRoot := TMapEuristicTree.Create(oInitialMap);
  // В качестве очереди вариантов будем использвоать очередь с сортировкой при вставке
  FPipe := TMapEuristicList.Create;
  // В качестве списка уникальных вариантов будем использвать простую очередь, как бы фигово это не звучало...
  FCheckList := TMapList.Create;

  // Кладем в очередь вариантов корень всего дерева - элемент с изначальной картой
  FPipe.Send(FRoot);
  // Его же, за его уникальность, сразу же кладем в очередь уникальных вариантов
  FCheckList.Send(FRoot);
  // Считаем количество всех возможных вариантов состояния поля...
  FComplexity := fact(oInitialMap.Width * oInitialMap.Height);

  // Запускаем алгоритм поиска пути. Ага, это именно TWidewayAI.FindWay
  Result := FindWay;
end;

(**
 * Метод для запуска алгоритма поиска в глубину
 *
 * Параметры:
 *   oInitialMap - изначальная карта, относительно которой нужно найти решение
 *
 * Возвращаемое значение:
 *   Возвращает true тогда, когда алгоритм смог найти хотя бы одно решение
 *
 *)
Function TDeepwayAI.Process(oInitialMap: TMap): boolean;
begin
  FMaxDeepLevel := 4 * (oInitialMap.Width * oInitialMap.Width - 1);
  Result := inherited Process(oInitialMap);
end;

(**
 * Алгоритм поиска в глубину
 *
 * Возвращаемое значение:
 *   Возвращает true тогда, когда было найдено хотя бы одно возможное решение
 *)
Function TDeepwayAI.FindWay: boolean;
var
  oActualStep: TMapTree; // Элемент текущего шага рекурсии
  oNextStep: TMapTree;   // Элемент, предположительно, следующего шага рекурсии
  iStepId: byte;         // Индекс хода для массива возможных ходов
  ptRootCenter: TPoint;  // Положение пустой клетки у корна текущего шага
  ptCenter: TPoint;      // Положение пустой клетки у текущего шага
  ptWalk: TPoint;        // Положение фишки, которая будет передвинута
  iCheckListId: integer; // Индекс чек-таблицы, для проверки элемента на повторения

begin
  Result := false;
  // Без изъятия из очереди, получаем элемент для текущего шага, удалять его будет кто-нибудь другой
  oActualStep := FPipe.Item[0];

  // Если текущий элемент удовлетворяет критериям цели, помечаем его
  // и выходим с положительным результатом
  if oActualStep.Map.IsValid then begin
    oActualStep.MarkAsComplited;
    Result := true;
    exit;
  end;

  // Если мы залезли слишком глубоко, то глубже лезть не уже не станем
  if FMaxDeepLevel < oActualStep.Depth then exit;

  // Получаем координаты пустой клетки элемента
  ptCenter := oActualStep.Map.GetEmptyCell;
  for iStepId := 0 to 3 do begin
    // Находим координаты фишки, которую надо двигать согласно текущему индексу хода
    with ptWalk do begin
      X := ptCenter.X + arMoveDirections[iStepId, 0];
      Y := ptCenter.Y + arMoveDirections[iStepId, 1];
    end;

    // Если такой ход сделать нельзя то переходим к следующему варианту хода
    if not oActualStep.Map.IsCellMovable(ptWalk.X, ptWalk.Y) then continue;

    // делаем проверку не повторяет ли этот ход предыдущий:
    // проверка делается пог местоположению пустой клетки
    if oActualStep.Root <> nil then begin
      //определяем координаты пустой клетки у поля корня текущего элемента.
      ptRootCenter := oActualStep.Root.Map.GetEmptyCell;
      //если ход равен предыдущему, то на следующий шаг цикла
      if (ptRootCenter.X = ptWalk.X) and (ptRootCenter.Y = ptWalk.Y) then continue;
    end;

    // Получаем отросток элемента для совершения хода
    oNextStep := oActualStep.MakeBranch;

    // Но если этот отросток лежит дальше найденного решения, делать с ним ничего не будем
    if (FRoot.Weight > 0) and (FRoot.Weight < oNextStep.Depth) then continue;

    // Осуществляем желаемый вариант хода
    oNextStep.Map.MoveCell(ptWalk.X, ptWalk.Y);

    // Делаем проверку, не встречался ли нам уже элемент с таким же состоянием поля
    iCheckListId := FCheckList.Count;
    while iCheckListId > 0  do begin
      dec(iCheckListId);
      if FCheckList.Item[iCheckListId].IsMapsEqual(oNextStep) then break;
    end;
    // Если встречался, то ничего с ним больше не делаем
    if
      (iCheckListId > 0) and
      (FCheckList.Item[iCheckListId].Depth <= oNextStep.Depth) and
      (FCheckList.Item[iCheckListId].Weight = 0)
    then continue;

    // Добавляем элемент в чек-лист, а вдруг он еще раз встретится?
    FCheckList.Send(oNextStep);
    // Сигнализируем наружу, что мы не спим, что работа во всю кипит ;-)
    ProcessEvent(FCheckList.Count, FComplexity);

    // Добавляем новый элемент в список по принципу стека
    FPipe.Push(oNextStep);
    // Углубляемся...
    if FindWay then Result := true;
    // Достаем элемент из стека, больше он, пожалуй, не понадобится
    FPipe.Recv;
    // Если на текущем шаге встретилась ситуация с выигрышем, то
    // можно не проверять остальные варианты ходов и сразу выйти наружу
    if Result and (oActualStep.Weight in [1..3]) then break;
  end;
end;

end.
