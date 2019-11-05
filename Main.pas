Program Cryme;
Uses Crt, SysUtils, DateUtils, DOS;

Type
	{Variables used by the Administrator. Necessary to the first run}
	adminData = Record
		name: String;
	end;

	{Variables used by the Prisoner. Necessary to the register form}
	prisonerData = Record
		name: String[50];
	end;

	{Variables used by the Visitor. Necessary to the register form}
	visitorData = Record
		name: String[50];
	end;

var
	option: Byte;

procedure loginPanel;
begin
	Write('User: ');
	Readln(credentail.user);

	Write('Password: ');
	Readln(credential.password);

	Writeln('Tentativas restantes: ');
	Writ
end;

procedure prisoner;
begin
	Writeln;
end;

procedure visitor;
begin
	
end;

Begin
	loginPanel;
	Writeln('Menu');
	Writeln('1. Prisoner');
	Writeln('2. Visitor');
	Writeln('3. Configururation');
	Writeln('4. Help (Documentation)');
End.
