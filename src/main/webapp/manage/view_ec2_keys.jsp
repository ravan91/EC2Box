<%
/**
 * Copyright 2013 Sean Kavanagh - sean.p.kavanagh6@gmail.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
%>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html>
<head>

    <jsp:include page="../_res/inc/header.jsp"/>

    <script type="text/javascript">



        function populateKeyNames() {
            $.getJSON('getKeyPairJSON.action?ec2Key.ec2Region='+$("#importEC2Key_ec2Key_ec2Region").val(), function(result) {

              $("#importEC2Key_ec2Key_keyNm option").remove();
                var options = $("#importEC2Key_ec2Key_keyNm");
                options.append($("<option />").val('').text('-Select Key Name-'));
                $.each(result, function() {
                    if(this.keyName!=null){
                        options.append($("<option />").val(this.keyName).text(this.keyName));
                    }
                });

              $("#importEC2Key_ec2Key_keyNm option[value='<s:property value="ec2Key.keyNm"/>']").attr("selected",true);
            });



        }

        $(document).ready(function() {



            $("#add_dialog").dialog({
                autoOpen: false,
                height: 200,
                width: 400,
                modal: true
            });

            $("#import_dialog").dialog({
                autoOpen: false,
                height: 425,
                width: 600,
                modal: true
            });

            //open add dialog
            $("#add_btn").button().click(function() {
                $("#add_dialog").dialog("open");
            });
            //open import dialog
           $("#import_btn").button().click(function() {
                $("#import_dialog").dialog("open");
            });
            //call delete action
            $(".del_btn").button().click(function() {
                var id = $(this).attr('id').replace("del_btn_", "");
                window.location = 'deleteEC2Key.action?ec2Key.id='+ id +'&ec2Key.ec2Region=<s:property value="ec2Key.ec2Region" />&sortedSet.orderByDirection=<s:property value="sortedSet.orderByDirection" />&sortedSet.orderByField=<s:property value="sortedSet.orderByField"/>';
            });
            //submit add or edit form
            $(".submit_btn").button().click(function() {
                $(this).parents('form:first').submit();
            });
            //close all forms
            $(".cancel_btn").button().click(function() {
                $("#add_dialog").dialog("close");
                $("#import_dialog").dialog("close");
            });

            $(".sort,.sortAsc,.sortDesc").click(function() {
                var id = $(this).attr('id')

                if ($('#viewEC2Keys_sortedSet_orderByDirection').attr('value') == 'asc') {
                    $('#viewEC2Keys_sortedSet_orderByDirection').attr('value', 'desc');

                } else {
                    $('#viewEC2Keys_sortedSet_orderByDirection').attr('value', 'asc');
                }

                $('#viewEC2Keys_sortedSet_orderByField').attr('value', id);
                $("#viewEC2Keys").submit();

            });
            <s:if test="sortedSet.orderByField!= null">
            $('#<s:property value="sortedSet.orderByField"/>').attr('class', '<s:property value="sortedSet.orderByDirection"/>');
            </s:if>


            $('.scrollableTable').tableScroll({height:500});
            $(".scrollableTable tr:odd").css("background-color", "#e0e0e0");
        });
    </script>


       <s:if test="fieldErrors.size > 0 || actionErrors.size >0">
            <script type="text/javascript">
                $(document).ready(function() {

                     populateKeyNames();

                    <s:if test="ec2Key.privateKey!=null">
                    $("#import_dialog").dialog("open");
                    </s:if>
                    <s:else>
                    $("#add_dialog").dialog("open");
                    </s:else>


                });
            </script>
        </s:if>



    <title>EC2Box - Manage EC2 Keys</title>

</head>
<body>

<div class="page">
    <jsp:include page="../_res/inc/navigation.jsp"/>

    <div class="content">

            <h3>Manage EC2 Keys</h3>

    <s:if test="hasActionMessages()">
        <s:actionmessage escape="false"/>
    </s:if>
    <s:else>
          <p>Import and register EC2 keys below. An EC2 server will only show after its private key has been imported</p>

            <p>
            <s:form action="viewEC2Keys">
            <s:hidden name="sortedSet.orderByDirection" />
            <s:hidden name="sortedSet.orderByField"/>
            </s:form>
            </p>

        <s:if test="sortedSet.itemList!= null && !sortedSet.itemList.isEmpty()">
                <table class="vborder scrollableTable">
                    <thead>
                    <tr>

                        <th id="<s:property value="@com.ec2box.manage.db.EC2KeyDB@SORT_BY_KEY_NM"/>" class="sort">Key Name</th>
                        <th id="<s:property value="@com.ec2box.manage.db.EC2KeyDB@SORT_BY_EC2_REGION"/>" class="sort">EC2 Region</th>
                        <th>&nbsp;</th>
                    </tr>
                    </thead>
                    <tbody>
                    <s:iterator var="ec2Key" value="sortedSet.itemList" status="stat">
                    <tr>
                        <td>
                                <s:property value="keyNm"/>
                        </td>
                        <td>
                        <s:set var="ec2Region" value="%{ec2Region}"/>
                        <s:property value="%{ec2RegionMap.get(#ec2Region)}"/>
                        </td>
                            <td>
                                <div id="del_btn_<s:property value="id"/>" class="del_btn" style="float:left">
                                    Delete
                                </div>
                                <div style="clear:both"></div>
                            </td>
                    </tr>
                    </s:iterator>
                    </tbody>
                </table>
        </s:if>

        <!--
            <div id="add_btn">Create New Key</div>
            <div id="add_dialog" title="Create New Key">
             <s:actionerror/>
                <s:form action="submitEC2Key" class="save_ec2Key_form_add">
                    <s:select name="ec2Key.ec2Region"  list="ec2RegionMap" label="EC2 Region" headerKey="" headerValue="-Select-" />
                    <s:textfield name="ec2Key.keyNm" label="Key Name" size="15"/>
                    <s:hidden name="sortedSet.orderByDirection"/>
                    <s:hidden name="sortedSet.orderByField"/>
                    <tr>
                    <td>&nbsp;</td>
                    <td>
                    <div class="submit_btn">Submit</div>
                    <div class="cancel_btn">Cancel</div>
                    </td>
                    </tr>
                </s:form>
            </div>
            -->

             <div id="import_btn">Import Private Key</div>
                        <div id="import_dialog" title="Import Existing EC2 Key">
                         <s:actionerror/>
                            <s:form action="importEC2Key" class="save_ec2Key_form_import">
                                <s:select name="ec2Key.ec2Region"  list="ec2RegionMap" label="EC2 Region" headerKey="" headerValue="-Select-" onchange="populateKeyNames();" />
                                <s:select name="ec2Key.keyNm" label="Key Name" list="#{'':'-Select Region Above-'}"/>
                                <s:textarea name="ec2Key.privateKey" label="Private Key Value"  rows="15" cols="35" wrap="off"/>
                                <s:hidden name="sortedSet.orderByDirection"/>
                                <s:hidden name="sortedSet.orderByField"/>
                                <tr>
                                <td>&nbsp;</td>
                                <td>
                                <div class="submit_btn">Submit</div>
                                <div class="cancel_btn">Cancel</div>
                                </td>
                                </tr>
                            </s:form>
             </div>

    </s:else>

    </div>
</div>
</body>
</html>
