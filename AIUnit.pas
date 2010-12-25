unit AIUnit;

interface

uses
  Windows, Classes, SysUtils, MapUnit;

Type
  TOnProcessEvent = Procedure (iStep: integer; iMax: integer) of object;

  TMapTree = class
    Protected
      FWeight: integer;
      FMap: TMap;
      FParent: TMapTree;
      FBranches: array[0..3] of TMapTree;

      Constructor Create(oParent: TMapTree); overload;

      Procedure init;
      Procedure AddBranch(oValue: TMapTree);
      Procedure DeleteBranch(oValue: TMapTree);

      Function GetBranch(index: integer): TMapTree;
      Function GetDepth: integer;

    Public
      Constructor Create(oMap: TMap); overload;
      Destructor Destroy; override;

      Function MakeBranch: TMapTree; virtual;
      Procedure ClearBranches;
      Procedure MarkAsComplited;
      Function IsMapsEqual(oMap: TMapTree): boolean;

      Property Root: TMapTree read FParent;
      Property Map: TMap read FMap;
      Property Branch[index: integer]: TMapTree read GetBranch;
      Property Weight: integer read FWeight;
      Property Depth: integer read GetDepth;
  end;

  TMapList = class
    Private
      FList: TList;

    Protected
      Function GetCount: integer;
      Function GetItem(iId: integer): TMapTree;

    Public
      Constructor Create;
      Destructor Destroy; override;

      Procedure Send(oMap: TMapTree); virtual;
      Function Recv: TMapTree;
      Procedure Clear;

      Property Count: integer read GetCount;
      Property Item[index: integer]: TMapTree read GetItem;
  end;

  TWaypointList = class;

  TWaypoint = class
    Private
      FList: TWaypointList;
      FX: integer;
      FY: integer;

    Public
      Constructor Create(X, Y: integer; oList: TWaypointList);
      Destructor Destroy; override;

      Property X: integer read FX;
      Property Y: integer read FY;
      Property Parent: TWaypointList read FList;
  end;

  TWaypointList = class
    Private
      FList: TList;

    Protected
      Procedure AddPoint(oPoint: TWaypoint);
      Procedure DeletePoint(oPoint: TWaypoint);

      Function GetCount: integer;
      Function GetPoint(iId: integer): TWaypoint;

    Public
      Constructor Create;
      Destructor Destroy; override;

      Function Add(X, Y: integer): TWaypoint;
      Procedure Delete(var oPoint: TWaypoint); overload;
      Procedure Delete(iId: integer); overload;
      Procedure Clear;

      Property Count: integer read GetCount;
      Property Point[index: integer]: TWaypoint read GetPoint;
  end;

  TWidewayAI = class
    Private
      FRoot: TMapTree;
      FPipe: TMapList;
      FCheckList: TMapList;
      FOnProcess: TOnProcessEvent;
      FComplexity: integer;

    Protected
      Function FindWay: boolean;
      Procedure ProcessEvent(iStep: integer; iMax: integer);

    Public
      Constructor Create;
      Destructor Destroy; override;

      Procedure Clear;
      Function Process(oInitialMap: TMap): boolean; virtual;
      Function GetRightPass(oWay: TWaypointList): boolean;

      Property Root: TMapTree read FRoot;
      Property OnProcess: TOnProcessEvent read FOnProcess write FOnProcess;
  end;

  TMapEuristicTree = class(TMapTree)
    Protected
      FCompleteness: integer;

      Function GetPointCompliteness(X, Y: integer): integer;
      
    Public
      Procedure FixCompletenessLevel;
      Function MakeBranch: TMapTree; override;

      Property Completeness: integer read FCompleteness;
  end;

  TMapEuristicList = class(TMapList)
    Protected
      Function PlaceItem(oNode: TMapEuristicTree; iLeftMargin, iRightMargin: integer): boolean;

    Public
      Procedure Send(oMap: TMapTree); override;
  end;

  TGradientAI = class(TWidewayAI)
    Public
      Function Process(oInitialMap: TMap): boolean; override;
  end;

implementation

uses Types;

function fact(X: integer): integer;
begin
  Result := X;
  while X > 2 do begin
    dec(X);
    Result := Result * X;
  end;
end;

Constructor TMapTree.Create(oParent: TMapTree);
begin
  Inherited Create;
  init;
  FParent := oParent;
  FParent.AddBranch(self);
  FMap := FParent.FMap.Peer;
end;

Constructor TMapTree.Create(oMap: TMap);
begin
  Inherited Create;
  init;
  FMap := oMap;
end;

Procedure TMapTree.init;
begin
  FillChar(FBranches, sizeof(FBranches), 0);
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

Procedure TMapTree.AddBranch(oValue: TMapTree);
var
  iBranchId: integer;
begin
  if FBranches[3] = nil then begin
    iBranchId := 0;
    while (3 >= iBranchId) and (nil <> FBranches[iBranchId]) do inc(iBranchId);
    FBranches[iBranchId] := oValue;
  end;
end;

Procedure TMapTree.DeleteBranch(oValue: TMapTree);
var
  iBranchId: integer;
begin
  iBranchId := 0;
  while (3 >= iBranchId) and (oValue <> FBranches[iBranchId]) do inc(iBranchId);
  if iBranchId > 3 then exit;
  while 3 > iBranchId do begin
    FBranches[iBranchId] := FBranches[iBranchId + 1];
    inc(iBranchId);
  end;
  FBranches[3] := nil;
end;

Function TMapTree.MakeBranch: TMapTree;
begin
  if FBranches[3] <> nil then Result := nil
  else Result := TMapTree.Create(self);
end;

Procedure TMapTree.MarkAsComplited;
var
  oRoot: TMapTree;
  iWeight: integer;
begin
  FWeight := 1;
  oRoot := FParent;
  iWeight := 2;
  while oRoot <> nil do begin
    if (oRoot.FWeight > 0) and (oRoot.FWeight < iWeight) then break;
    oRoot.FWeight := iWeight;
    inc(iWeight);
    oRoot := oRoot.Root;
  end;
end;

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

Function TMapTree.GetBranch(index: integer): TMapTree;
begin
  Result := nil;
  if (0 > index) or (3 < index) then exit;
  Result := FBranches[index];
end;

Function TMapTree.GetDepth: integer;
var
  oRoot: TMapTree;
begin
  Result := 1;
  oRoot := FParent;
  while oRoot <> nil do begin
    inc(Result);
    oRoot := oRoot.Root;
  end;
end;

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

Procedure TMapList.Send(oMap: TMapTree);
begin
  FList.Add(oMap);
end;

Function TMapList.Recv: TMapTree;
begin
  Result := nil;
  if FList.Count < 1 then exit;
  Result := TMapTree(FList.Items[0]);
  FList.Delete(0);
end;

Procedure TMapList.Clear;
begin
  while FList.Count > 0 do FList.Delete(0);
end;

Function TMapList.GetCount: integer;
begin
  Result := FList.Count;
end;

Function TMapList.GetItem(iId: integer): TMapTree;
begin
  Result := nil;
  if (0 > iId) or (FList.Count <= iId) then exit;
  Result := TMapTree(FList.Items[iId]);
end;

Constructor TWaypoint.Create(X, Y: integer; oList: TWaypointList);
begin
  inherited Create;
  FX := X;
  FY := Y;
  FList := oList;
  FList.AddPoint(self);
end;

Destructor TWaypoint.Destroy;
begin
  FList.DeletePoint(self);
  inherited;
end;

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

Function TWaypointList.Add(X, Y: integer): TWaypoint;
begin
  Result := TWaypoint.Create(X, Y, self);
end;

Procedure TWaypointList.Delete(var oPoint: TWaypoint);
begin
  oPoint.Free;
  oPoint := nil;
end;

Procedure TWaypointList.Delete(iId: integer);
var
  oPoint: TWaypoint;
begin
  oPoint := TWaypoint(FList.Items[iId]);
  Delete(oPoint);
end;

Procedure TWaypointList.Clear;   
begin
  while FList.Count > 0 do TWaypoint(FList.Items[0]).Free;
end;

Procedure TWaypointList.AddPoint(oPoint: TWaypoint);
begin
  FList.Add(oPoint);
end;

Procedure TWaypointList.DeletePoint(oPoint: TWaypoint);
begin
  FList.Remove(oPoint);
end;

Function TWaypointList.GetCount: integer; 
begin
  Result := FList.Count;
end;

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

Function TWidewayAI.Process(oInitialMap: TMap): boolean;
begin
  if FRoot <> nil then Clear;
  FRoot := TMapTree.Create(oInitialMap);
  FPipe := TMapList.Create;
  FCheckList := TMapList.Create;
  FPipe.Send(FRoot);
  FCheckList.Send(FRoot);
  FComplexity := fact(oInitialMap.Width * oInitialMap.Height);
  Result := FindWay;
end;

Function TWidewayAI.FindWay: boolean;
var
  oCurMap: TMapTree;
  oNewMap: TMapTree;
  ptCenter: TPoint;
  ptRootCenter: TPoint;
  ptWalk: TPoint;
  iStepId: integer;
  iCheckListId: integer;
begin
  Result := false;
  while FPipe.Count > 0 do begin
    oCurMap := FPipe.Recv;
    ptCenter := oCurMap.Map.GetEmptyCell;
    for iStepId := 0 to 3 do begin
      with ptWalk do begin
        X := ptCenter.X + arMoveDirections[iStepId, 0];
        Y := ptCenter.Y + arMoveDirections[iStepId, 1];
      end;
      if not oCurMap.Map.IsCellMovable(ptWalk.X, ptWalk.Y) then continue;
      if oCurMap.Root <> nil then begin
        ptRootCenter := oCurMap.Root.Map.GetEmptyCell;
        if (ptRootCenter.X = ptWalk.X) and (ptRootCenter.Y = ptWalk.Y) then continue;
      end;

      oNewMap := oCurMap.MakeBranch;
      if (FRoot.Weight > 0) and (FRoot.Weight < oNewMap.Depth) then continue;
      oNewMap.Map.MoveCell(ptWalk.X, ptWalk.Y);
      if oNewMap.Map.IsValid then begin
        oNewMap.MarkAsComplited;
        Result := true;
      end else begin
        iCheckListId := FCheckList.Count;
        while iCheckListId > 0  do begin
          dec(iCheckListId);
          if FCheckList.Item[iCheckListId].IsMapsEqual(oNewMap) then break;
        end;
        if iCheckListId = 0 then begin
          FCheckList.Send(oNewMap);
          FPipe.Send(oNewMap);
        end;
      end;
      ProcessEvent(FCheckList.Count, FComplexity);
    end;
  end;
end;

Procedure TWidewayAI.ProcessEvent(iStep: integer; iMax: integer);
begin
  if not assigned(FOnProcess) then exit;
  FOnProcess(iStep, iMax);
end;

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
    for iBranchId := 0 to 3 do begin
      if oNode.Branch[iBranchId] = nil then continue;
      if (iWayWeight = 0) or (oNode.Branch[iBranchId].Weight < iWayWeight) then begin
        if oNode.Branch[iBranchId].Weight = 0 then continue;
        iWayWeight := oNode.Branch[iBranchId].Weight;
        iWayBranch := iBranchId;
      end;
    end;
    if iWayWeight > 0 then begin
      ptWaypoint := oNode.Branch[iWayBranch].Map.GetEmptyCell;
      oWay.Add(ptWaypoint.X, ptWaypoint.Y);
      oNode := oNode.Branch[iWayBranch];
      Result := oNode.Weight = 1;
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

Function TMapEuristicTree.GetPointCompliteness(X, Y: integer): integer;
var
  ActualX: integer;
  ActualY: integer;
  BaseValue: integer;
begin
  Result := 0;
  BaseValue := FMap.Cell[X, Y];
  if BaseValue = 0 then exit;

  (*ActualX := X;
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
  (*)
  ActualX := X + 1;
  ActualY := Y;
  while ActualX < FMap.Width do begin
    if (FMap.Cell[ActualX, ActualY] <> 0) and (FMap.Cell[ActualX, ActualY] < BaseValue) then inc(Result);
    inc(ActualX);
  end;
  ActualX := X;
  ActualY := Y + 1;
  while ActualY < FMap.Height do begin
    if (FMap.Cell[ActualX, ActualY] <> 0) and (FMap.Cell[ActualX, ActualY] < BaseValue) then inc(Result);
    inc(ActualY);
  end;
  //*)
  (*)
  BaseValue := FMap.Cell[X, Y];
  ActualX := BaseValue mod FMap.Width - 1;
  ActualY := BaseValue div FMap.Width;
  Result := abs(X - ActualX) + abs(Y - ActualY);
  //*)
  (*ActualX := X;
  ActualY := Y;
  inc(ActualY);
  while ActualX < FMap.Width do begin
    while ActualY < FMap.Height do begin
      if (FMap.Cell[ActualX, ActualY] <> 0) and (FMap.Cell[ActualX, ActualY] < BaseValue) then inc(Result);
      inc(ActualY);
    end;
    ActualY := 0;
    inc(ActualX);
  end;//*)
end;

Procedure TMapEuristicTree.FixCompletenessLevel;
var
  ActualX: integer;
  ActualY: integer;
begin
  FCompleteness := FMap.GetEmptyCell.Y + 1;
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

Function TMapEuristicTree.MakeBranch: TMapTree;
begin
  if FBranches[3] <> nil then Result := nil
  else Result := TMapEuristicTree.Create(self);
end;

Procedure TMapEuristicList.Send(oMap: TMapTree);
begin
  if not (oMap is TMapEuristicTree) then exit;
  TMapEuristicTree(oMap).FixCompletenessLevel;
  if not PlaceItem(TMapEuristicTree(oMap), 0, FList.Count - 1) then inherited Send(oMap);
end;

Function TMapEuristicList.PlaceItem(oNode: TMapEuristicTree; iLeftMargin, iRightMargin: integer): boolean;
var
  oLeftNode: TMapEuristicTree;
  oRightNode: TMapEuristicTree;
  oMidNode: TMapEuristicTree;
  iMidMargin: integer;
begin
  Result := false;
  if iRightMargin < iLeftMargin then exit;
  oLeftNode  := TMapEuristicTree(FList.Items[iLeftMargin]);
  if iRightMargin = iLeftMargin then begin
    if oNode.Completeness > oLeftNode.Completeness then inc(iLeftMargin);
    FList.Insert(iLeftMargin, oNode);
    Result := true;
    exit;
  end;
  if oNode.Completeness <= oLeftNode.Completeness then begin
    FList.Insert(iLeftMargin, oNode);
    Result := true;
    exit;
  end;
  oRightNode := TMapEuristicTree(FList.Items[iRightMargin]);
  if oNode.Completeness >= oRightNode.Completeness then begin
    FList.Insert(iRightMargin + 1, oNode);
    Result := true;
    exit;
  end;

  iMidMargin := (iRightMargin - iLeftMargin) div 2;
  if iMidMargin = 0 then iMidMargin := 1;
  inc(iMidMargin, iLeftMargin);
  oMidNode := TMapEuristicTree(FList.Items[iLeftMargin]);
  if oNode.Completeness > oMidNode.Completeness then
    Result := PlaceItem(oNode, iMidMargin, iRightMargin)
  else
    Result := PlaceItem(oNode, iLeftMargin, iMidMargin);
end;

Function TGradientAI.Process(oInitialMap: TMap): boolean;
begin
  if FRoot <> nil then Clear;
  FRoot := TMapEuristicTree.Create(oInitialMap);
  FPipe := TMapEuristicList.Create;
  FCheckList := TMapList.Create;
  FPipe.Send(FRoot);
  FCheckList.Send(FRoot);
  FComplexity := fact(oInitialMap.Width * oInitialMap.Height);
  Result := FindWay;
end;

end.
