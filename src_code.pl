/*------------------------------------------------------------------------
%%% Project "Κατασκευή Προγράμματος Μαθημάτων" για το μάθημα 
%%% Υπολογιστική Λογική και Λογικός Προγραμματισμός για το εαρινό εξάμηνο 
%%% του 2018 από τους ****Ταραμά Στέφανο(2415)**** και ****Χίρτογλου Μάριο(2426)****.
------------------------------------------------------------------------*/


/*
Εισαγωγή του αρχείου attends.pl κάτω από το ίδιο directory.
Το αρχείο περιέχει κατηγορήματα της μορφής attends(ΑΕΜ, κωδικός_μαθήματος).
*/
:- [attends].


/*
Επιστρέφει ενα τυχαίο πρόγραμμα εξετάσεων.
Α,Β,C είναι οι εβδομάδες.
Μέσω backtracking επιστρέφονται όλοι οι δυνατοί συνδιασμοί.
*/
schedule(A,B,C):-
	/*Δημιουργία μίας λίστας με όλα τα Courses, από την "Βάσει Δεδομένων"*/
	findall(Course, (attends(_Aem,Course) ) ,ListCourses),
	/*Μεταμόρφωση της λίστας σε σύνολο για να διαγραφούν τυχόν διπλότυπα*/
	list_to_set(ListCourses,Courses),
	/*Δημιουργία μεταθέσεων των Courses και κατ' επέκταση τυχαίον προγραμμάτων*/
	permutation(Courses,[A1,A2,A3,B1,B2,B3,C1,C2]),
	A = [A1,A2,A3],
	B = [B1,B2,B3],
	C = [C1,C2].
	

/*
Επιστρέφει τον αριθμό των φοιτητών που είναι δυσαρεστημένοι(3 μαθήματα/εβδομάδα) 
*/		
schedule_errors([A1,A2,A3],[B1,B2,B3],[_C1,_C2],E):-
	
        
	/*Δημιουργία μίας λίστας με όλα τα ΑΕΜ, από την "Βάση Δεδομένων"*/
	findall(Aem, (attends(Aem,_Course) ) ,ListAems),
	/*Μεταμόρφωση της λίστας σε σύνολο για να διαγραφούν τυχόν διπλότυπα*/
	list_to_set(ListAems,Aems),
	/*Υπολογίζονται τα errors μόνο για την 1η και 2η εβδομάδα, αφού η 3η έχει μόνο 2 μέρες 
	εξέτασης και δεν είναι δυνατόν να παραχθεί error*/
	schedule_errors_OfOneWeek([A1,A2,A3],Aems,Eof1st),
	schedule_errors_OfOneWeek([B1,B2,B3],Aems,Eof2nd),
	
	/*Το συνολικό πλήθος από errors*/
	E is Eof1st + Eof2nd,
	!.


/*
Επιστρέφει το πλήθος των δυσαρεστημένων μαθητών για μία εβδομάδα
*/
schedule_errors_OfOneWeek([_Course1,_Course2,_Course3],[],Score):-
	Score is 0.
/*
	score(attends(LastAem,Course1),attends(LastAem,Course2),attends(LastAem,Course3),Score).
*/

/*Για κάθε ΑΕΜ υπολογίζει πόσους δυσαρεστημένους μαθητές δημιουργεί το εκάστοτε πρόγραμμα για 
μία εβδομάδα*/
schedule_errors_OfOneWeek([Course1,Course2,Course3],[Aem|Tail],Score):-
	
	schedule_errors_OfOneWeek([Course1,Course2,Course3],Tail,PreviousScore),
	score([Course1,Course2,Course3],Aem,ThisScore),
	Score is PreviousScore + ThisScore.
/*
Υπολογίζει το σκορ μιας εβδομάδας για έναν συγκεκριμένο μαθητή.
*/
score([Course1,Course2,Course3],Aem,Score):-
	not(attends(Aem,Course1)),
	not(attends(Aem,Course2)),
	not(attends(Aem,Course3)),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	not(attends(Aem,Course1)),
	not(attends(Aem,Course2)),
	attends(Aem,Course3),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	not(attends(Aem,Course1)),
	attends(Aem,Course2),
	not(attends(Aem,Course3)),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	not(attends(Aem,Course1)),
	attends(Aem,Course2),
	attends(Aem,Course3),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	attends(Aem,Course1),
	not(attends(Aem,Course2)),
	not(attends(Aem,Course3)),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	attends(Aem,Course1),
	not(attends(Aem,Course2)),
	attends(Aem,Course3),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	attends(Aem,Course1),
	attends(Aem,Course2),
	not(attends(Aem,Course3)),
	Score is 0.
score([Course1,Course2,Course3],Aem,Score):-
	attends(Aem,Course1),
	attends(Aem,Course2),
	attends(Aem,Course3),
	Score is 1.


/*
Επιστρέφει ένα πρόγραμμα μαθημάτων με τον ελάχιστό αριθμό δυσαρεστημένων μαθητών.
*/
minimal_schedule_errors(A,B,C,MinError):-
	
	/*Βρίσκει όλα τα δυνατά error*/
	findall(X,( schedule(A1,B1,C1),schedule_errors(A1,B1,C1,X) ), ListOfErrors),
	/*Βρίσκει το minimum error μέσα στην λίστα μ' όλα τα errors*/	
	min_list(ListOfErrors,MinError),
	/*Μέσω backtracking παράγονται τα διαφορετικά προγράμματα με το ελάχιστο error*/
	schedule(A,B,C),
	schedule_errors(A,B,C,MinError).


/*
Επιστρέφει το σκορ ενός προγράμματος
*/
score_schedule(A,B,C,S):-
	/*Δημιουργία μίας λίστας με όλα τα ΑΕΜ, από την "Βάση Δεδομένων"*/
	findall(Aem, (attends(Aem,_Course) ) ,ListAems),
	/*Μεταμόρφωση της λίστας σε σύνολο για να διαγραφούν τυχόν διπλότυπα*/
	list_to_set(ListAems,Aems),
	/*Σκορ 1ης εβδομάδας*/	
	week_score(A,Aems,Score1),
	/*Σκορ 2ης εβδομάδας*/	
	week_score(B,Aems,Score2),
	/*Σκορ 3ης εβδομάδας*/
	week_score(C,Aems,Score3),
	/*Συνολικό σκορ προγράμματος*/
	S is Score1+Score2+Score3.

/*Σκορ μιας εβδομάδας(1ης ή 2ης) για όλους τους μαθητές*/
week_score([C1,C2,C3],[H|Tail],Score):-
	week_score([C1,C2,C3],Tail,PreviousScore),
	calculate_score([C1,C2,C3],H,ThisScore),
	Score is ThisScore + PreviousScore.
/*Τερματική συνθήκη*/
week_score([_C1,_C2,_C3],[],Score):-
	Score is 0.

/*Σκορ μιας εβδομάδας(3ης) για όλους τους μαθητές*/
week_score([C1,C2],[H|Tail],Score):-
	week_score([C1,C2],Tail,PreviousScore),
	calculate_score([C1,C2],H,ThisScore),
	Score is ThisScore + PreviousScore.
/*Τερματική συνθήκη*/
week_score([_C1,_C2],[],Score):-
	Score is 0.

/*Υπολογισμός του σκορ μιας εβδομάδας(1ης ή 2ης)*/
calculate_score([C1,C2,C3],Aem,WeekScore):-
	attends(Aem,C1),attends(Aem,C2),attends(Aem,C3),
	WeekScore is -7.
calculate_score([C1,C2,C3],Aem,WeekScore):-
	attends(Aem,C1),attends(Aem,C2),not(attends(Aem,C3)),
	WeekScore is 1.
calculate_score([C1,C2,C3],Aem,WeekScore):-
	not(attends(Aem,C1)),attends(Aem,C2),attends(Aem,C3),
	WeekScore is 1.
calculate_score([C1,C2,C3],Aem,WeekScore):-
	attends(Aem,C1),not(attends(Aem,C2)),attends(Aem,C3),
	WeekScore is 3.
calculate_score([C1,C2,C3],Aem,WeekScore):-
	not(attends(Aem,C1)),not(attends(Aem,C2)),not(attends(Aem,C3)),
	WeekScore is 0.
calculate_score([C1,C2,C3],Aem,WeekScore):-
	( ( attends(Aem,C1),not(attends(Aem,C2)),not(attends(Aem,C3)) );
	( not(attends(Aem,C1)),attends(Aem,C2),not(attends(Aem,C3)) );
	( not(attends(Aem,C1)),not(attends(Aem,C2)),attends(Aem,C3) ) ),
	WeekScore is 7.

/*Υπολογισμός του σκορ μιας εβδομάδας(3ης)*/
calculate_score([C1,C2],Aem,WeekScore):-
	attends(Aem,C1),attends(Aem,C2),
	WeekScore is 1.
calculate_score([C1,C2],Aem,WeekScore):-
	not(attends(Aem,C1)),not(attends(Aem,C2)),
	WeekScore is 0.
calculate_score([C1,C2],Aem,WeekScore):-
	( ( attends(Aem,C1),not(attends(Aem,C2)) );
	 ( not(attends(Aem,C1)),attends(Aem,C2)) ),
	WeekScore is 7.

/*Υπολογισμός προγράμματος εξετάσεων με το μικρότερο δυνατό αριθμό 
"δυσαρεστημένων" μαθητών και με το μεγαλύτερο δυνατό σκορ.*/
maximum_score_schedule(A,B,C,E,S):-
	/*Το S είναι το μέγιστο σκορ για το Ε το ελάχιστο πλήθος "δυσαρεστημένων" μαθητών*/	
	maxScoreOfMinErrors(E,S),	
	/*Παραγωγή προγράμματος με το ελάχιστο πλήθος "δυσαρεστημένων" και το μέγιστο σκορ
	και με χρήση του backtracking, εμφάνιση και των ισοδύναμων αλλά διαφορετικών προγραμμάτων*/
	minimal_schedule_errors(A,B,C,E),
	score_schedule(A,B,C,S).
	
	
	
/*Βρίσκει το μέγιστο σκορ από το σύνολο το προγραμμάτων με το 
ελάχιστο πλήθος "δυσαρεστημένων" μαθητών*/
maxScoreOfMinErrors(E,S):-
	/*Παραγωγή προγράμματος με το ελάχιστο πλήθος "δυσαρεστημένων"*/
	minimal_schedule_errors(_A,_B,_C,E),
	findall(Score,(	minimal_schedule_errors(A,B,C,E),score_schedule(A,B,C,Score) ), Scores),
	max_list(Scores,S),!.	
	
















