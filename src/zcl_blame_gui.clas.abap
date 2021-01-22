CLASS zcl_blame_gui DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !io_parts TYPE REF TO zcl_blame_parts .

    METHODS display
      RAISING
        zcx_blame .

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA go_parts TYPE REF TO zcl_blame_parts.
    DATA go_viewer TYPE REF TO zcl_blame_gui_viewer.
    DATA go_handler TYPE REF TO zcl_blame_gui_handler.

    METHODS pre_render_part_lines
      IMPORTING
                it_line        TYPE zblame_line_t
      RETURNING VALUE(rt_blame) TYPE zblame_line_t.

    METHODS get_pre_rendered_data
      RETURNING VALUE(rs_data) TYPE zblame_parts
      RAISING   zcx_blame.
ENDCLASS.



CLASS zcl_blame_gui IMPLEMENTATION.


  METHOD constructor.
    me->go_parts = io_parts.
    me->go_handler = NEW #( me ).
    me->go_viewer = NEW #( go_handler ).
  ENDMETHOD.


  METHOD display.
    DATA(s_data) = get_pre_rendered_data( ).
    go_viewer->render( s_data ).
  ENDMETHOD.


  METHOD pre_render_part_lines.
    DATA(o_highlighter) = NEW zcl_blame_syntax_abap( ).
    DATA s_previous LIKE LINE OF it_line.

    LOOP AT it_line INTO DATA(s_line).
      IF s_line-line_num <> 1 AND s_line-version_number = s_previous-version_number.
        CLEAR s_line-author.
        CLEAR s_line-author_name.
        CLEAR s_line-version_number.
        CLEAR s_line-request.
        CLEAR s_line-date.
        CLEAR s_line-time.
      ELSE.
        s_previous = s_line.
      ENDIF.
      s_line-source = o_highlighter->process_line(  CONV #( s_line-source ) ).
      INSERT s_line INTO TABLE rt_blame.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_pre_rendered_data.
    rs_data = me->go_parts->get_data( ).
    LOOP AT rs_data-t_part REFERENCE INTO DATA(o_part).
      o_part->t_line = pre_render_part_lines( o_part->t_line ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
