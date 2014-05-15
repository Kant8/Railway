USE Railway
GO

create trigger CheckWagonCount
on Wagon
after insert
as
declare @trainId int, @wagonsCount int, @maxWagonsCount int

select @trainId = TrainId from inserted

select @wagonsCount = count(*) from Wagon as w
where w.TrainId = @trainId

select @maxWagonsCount = t.MaxWagonCount from Train as t
where t.Id = @trainId

if @wagonsCount >= @maxWagonsCount
begin
	rollback transaction	
end


