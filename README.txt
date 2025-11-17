TCNOpen TRDP prototype stack

*******************************************************************************************************
* Please see:
        'TCN-TRDP2-D-BOM-019-10 TRDP SYSTEM ARCHITECTURE & DESIGN SPECIFICATION'
(https://www.cooperationtool.eu/tcnopen/goto.aspx?p=TCNOPEN&doc=f32ef583-5601-43dd-b1df-d5a8f309ffab)
        'TCN-TRDP2-D-BOM-011-31 TRDP USER'S MANUAL'
(https://www.cooperationtool.eu/tcnopen/goto.aspx?p=TCNOPEN&doc=e8a3340b-249b-49b6-b39a-41e780787c0d)
        
        for further information.
*******************************************************************************************************

1. By default th SOA_SUPPORT shall be disable.
2. to turn this option, the Project shall add the meta below in its project (component.xml) 
   <!-- Set the TRDP SAO Support enable-->
   <meta name="trdp:soa_support" type="bool" default="true"/>

