<%
/**
 * Copyright (c) 2000-2009 Liferay, Inc. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
%>

<%@ include file="/html/portlet/bookmarks/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

BookmarksFolder folder = (BookmarksFolder)request.getAttribute(WebKeys.BOOKMARKS_FOLDER);

long folderId = BeanParamUtil.getLong(folder, request, "folderId");

long parentFolderId = BeanParamUtil.getLong(folder, request, "parentFolderId", BookmarksFolderImpl.DEFAULT_PARENT_FOLDER_ID);
%>

<script type="text/javascript">
	function <portlet:namespace />removeFolder() {
		document.<portlet:namespace />fm.<portlet:namespace />parentFolderId.value = "<%= BookmarksFolderImpl.DEFAULT_PARENT_FOLDER_ID %>";

		var nameEl = document.getElementById("<portlet:namespace />parentFolderName");

		nameEl.href = "";
		nameEl.innerHTML = "";

		jQuery("#<portlet:namespace />merge-with-parent-checkbox-div").hide();
		jQuery("#<portlet:namespace />mergeWithParentFolderCheckbox").attr("checked", false);
	}

	function <portlet:namespace />saveFolder() {
		document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "<%= folder == null ? Constants.ADD : Constants.UPDATE %>";
		submitForm(document.<portlet:namespace />fm);
	}

	function <portlet:namespace />selectFolder(parentFolderId, parentFolderName) {
		document.<portlet:namespace />fm.<portlet:namespace />parentFolderId.value = parentFolderId;

		var nameEl = document.getElementById("<portlet:namespace />parentFolderName");

		nameEl.href = "<portlet:renderURL windowState="<%= WindowState.MAXIMIZED.toString() %>"><portlet:param name="struts_action" value="/bookmarks/view" /></portlet:renderURL>&<portlet:namespace />folderId=" + parentFolderId;
		nameEl.innerHTML = parentFolderName + "&nbsp;";

		if (parentFolderId != <%= BookmarksFolderImpl.DEFAULT_PARENT_FOLDER_ID %>) {
			jQuery("#<portlet:namespace />merge-with-parent-checkbox-div").show();
		}
	}
</script>

<portlet:actionURL windowState="<%= WindowState.MAXIMIZED.toString() %>" var="editFolderURL">
	<portlet:param name="struts_action" value="/bookmarks/edit_folder" />
</portlet:actionURL>

<aui:form action="<%= editFolderURL %>" method="post" name="fm" onSubmit='<%= renderResponse.getNamespace() + "saveFolder(); return false;" %>'>
	<aui:input name="<%= Constants.CMD %>" type="hidden" />
	<aui:input name="redirect" type="hidden" value="<%= redirect %>" />
	<aui:input name="folderId" type="hidden" value="<%= folderId %>" />
	<aui:input name="parentFolderId" type="hidden" value="<%= parentFolderId %>" />

	<liferay-ui:tabs
		names="folder"
		backURL="<%= redirect %>"
	/>

	<liferay-ui:error exception="<%= FolderNameException.class %>" message="please-enter-a-valid-name" />

	<aui:model-context bean="<%= folder %>" model="<%= BookmarksFolder.class %>" />

	<aui:fieldset>
		<c:if test="<%= folder != null %>">
			<aui:field-wrapper label="parent-folder">
				<%
				String parentFolderName = "";

				try {
					BookmarksFolder parentFolder = BookmarksFolderLocalServiceUtil.getFolder(parentFolderId);

					parentFolderName = parentFolder.getName();
				}
				catch (NoSuchFolderException nscce) {
				}
				%>
				<portlet:renderURL windowState="<%= WindowState.MAXIMIZED.toString() %>" var="viewFolderURL">
					<portlet:param name="struts_action" value="/bookmarks/view" />
					<portlet:param name="folderId" value="<%= String.valueOf(parentFolderId) %>" />
				</portlet:renderURL>

				<aui:a href="<%= viewFolderURL %>" id="parentFolderName"><%= parentFolderName %></aui:a>

				<portlet:renderURL windowState="<%= LiferayWindowState.POP_UP.toString() %>" var="selectFolderURL">
					<portlet:param name="struts_action" value="/bookmarks/select_folder" />
					<portlet:param name="folderId" value="<%= String.valueOf(parentFolderId) %>" />
				</portlet:renderURL>

				<%
				String taglibOpenFolderWindow = "var folderWindow = window.open('" + selectFolderURL + "','folder', 'directories=no,height=640,location=no,menubar=no,resizable=yes,scrollbars=yes,status=no,toolbar=no,width=680'); void(''); folderWindow.focus();";
				%>

				<aui:button onClick='<%= taglibOpenFolderWindow %>' value="select" />

				<aui:button name="removeFolderButton" value="remove" onClick='<%= renderResponse.getNamespace() + "removeFolder();" %>' />

				<div id="<portlet:namespace />merge-with-parent-checkbox-div" <%= folder.getParentFolderId() == BookmarksFolderImpl.DEFAULT_PARENT_FOLDER_ID ? "style=\"display: none;\"" : StringPool.BLANK %>>
					<aui:input inlineLabel="<%= true %>" label="merge-with-parent-folder" name="mergeWithParentFolder" type="checkbox" />
				</div>
			</aui:field-wrapper>
		</c:if>

		<aui:input name="name" />

		<aui:input name="description" />

		<liferay-ui:custom-attributes-available className="<%= BookmarksFolder.class.getName() %>">
			<liferay-ui:custom-attribute-list
				className="<%= BookmarksFolder.class.getName() %>"
				classPK="<%= (folder != null) ? folder.getFolderId() : 0 %>"
				editable="<%= true %>"
				label="<%= true %>"
			/>
		</liferay-ui:custom-attributes-available>

		<c:if test="<%= folder == null %>">
			<aui:field-wrapper label="permissions">
				<liferay-ui:input-permissions
					modelName="<%= BookmarksFolder.class.getName() %>"
				/>
			</aui:field-wrapper>
		</c:if>
	</aui:fieldset>

	<aui:button-row>
		<aui:button type="submit" value="save" />

		<aui:button value="cancel" onClick="<%= redirect %>" />
	</aui:button-row>
</aui:form>

<c:if test="<%= windowState.equals(WindowState.MAXIMIZED) || windowState.equals(LiferayWindowState.POP_UP) %>">
	<script type="text/javascript">
		Liferay.Util.focusFormField(document.<portlet:namespace />fm.<portlet:namespace />name);
	</script>
</c:if>

<%
if (folder != null) {
	BookmarksUtil.addPortletBreadcrumbEntries(folderId, request, renderResponse);

	PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, "update-folder"), currentURL);
}
else {
	if (parentFolderId > 0) {
		BookmarksUtil.addPortletBreadcrumbEntries(parentFolderId, request, renderResponse);
	}

	PortalUtil.addPortletBreadcrumbEntry(request, LanguageUtil.get(pageContext, "add-folder"), currentURL);
}
%>