"! Takes an object type and name, calculates the blame information for the source
"! code of all its parts and displays it as HTML.
REPORT zblame.

DATA: vrsd TYPE vrsd.

SELECTION-SCREEN BEGIN OF BLOCK sel WITH FRAME TITLE TEXT-sel.
PARAMETERS p_otype TYPE zblame_object_type AS LISTBOX VISIBLE LENGTH 25 OBLIGATORY DEFAULT 'PROG'.
PARAMETERS p_name TYPE sobj_name OBLIGATORY.
SELECTION-SCREEN END OF BLOCK sel.

SELECTION-SCREEN BEGIN OF BLOCK filters WITH FRAME TITLE TEXT-flt.
PARAMETERS p_date TYPE datum OBLIGATORY DEFAULT sy-datum.
PARAMETERS p_time TYPE uzeit OBLIGATORY DEFAULT '235959'.
SELECTION-SCREEN END OF BLOCK filters.

SELECTION-SCREEN BEGIN OF BLOCK mode WITH FRAME TITLE TEXT-mde.
PARAMETERS p_mblame RADIOBUTTON GROUP mode USER-COMMAND mode DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF BLOCK options WITH FRAME TITLE TEXT-opt.
PARAMETERS p_icase AS CHECKBOX MODIF ID bla.
PARAMETERS p_iinde AS CHECKBOX MODIF ID bla.
SELECTION-SCREEN END OF BLOCK options.

PARAMETERS p_mtmach RADIOBUTTON GROUP mode.
SELECTION-SCREEN END OF BLOCK mode.

*SELECTION-SCREEN BEGIN OF BLOCK output WITH FRAME TITLE TEXT-out.
*PARAMETERS p_theme TYPE zblame_theme AS LISTBOX VISIBLE LENGTH 15 DEFAULT 'LIGHT'.
*SELECTION-SCREEN END OF BLOCK output.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'BLA' AND p_mblame IS INITIAL.
      screen-active = '0'.
      MODIFY SCREEN.
      CONTINUE.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.
  " Convert radio button to mode
  DATA(mode) = SWITCH zblame_mode(
    p_mblame
    WHEN abap_true THEN zif_blame_consts=>mode-blame
    ELSE zif_blame_consts=>mode-time_machine ).

  TRY.
      zcl_blame_options=>get_instance( )->set( i_mode               = mode
                                               i_ignore_case        = p_icase
                                               i_ignore_indentation = p_iinde
                                               i_timestamp = CONV #( |{ p_date }{ p_time }| ) ).

      NEW zcl_blame_run( )->go( i_object_type = p_otype
                                i_object_name = p_name ).
    CATCH zcx_blame INTO DATA(o_exp).
      MESSAGE o_exp TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.
