import { ComponentType, UIElement } from '../types';
import { isContainerType } from './liaComponentDefinitions';

const GMOD_CONTAINER_TYPES = new Set<ComponentType>([
  ComponentType.DFrame,
  ComponentType.DPanel,
  ComponentType.DScrollPanel,
  ComponentType.DPropertySheet,
  ComponentType.DColumnSheet,
  ComponentType.DTab,
  ComponentType.DForm,
  ComponentType.DCollapsibleCategory,
  ComponentType.DVerticalDivider,
  ComponentType.DBevel,
  ComponentType.DGrid,
  ComponentType.DIconLayout,
]);

export const canAcceptChildren = (type: ComponentType) => GMOD_CONTAINER_TYPES.has(type) || isContainerType(type);

export const getTopLevelIds = (elements: Record<string, UIElement>) =>
  Object.values(elements)
    .filter(element => !element.parentId || !elements[element.parentId])
    .map(element => element.id);

export const getPrimaryRootId = (elements: Record<string, UIElement>, preferredId: string | null = null) => {
  if (preferredId && elements[preferredId] && (!elements[preferredId].parentId || !elements[elements[preferredId].parentId!])) {
    return preferredId;
  }
  return getTopLevelIds(elements)[0] || null;
};

export const getDescendantIds = (elements: Record<string, UIElement>, id: string) => {
  const descendants = new Set<string>();
  const stack = [...(elements[id]?.children || [])];
  while (stack.length > 0) {
    const childId = stack.pop()!;
    if (descendants.has(childId)) continue;
    descendants.add(childId);
    const child = elements[childId];
    if (child) stack.push(...child.children);
  }
  return descendants;
};

export const getAbsolutePosition = (elements: Record<string, UIElement>, id: string) => {
  let x = 0;
  let y = 0;
  let current = elements[id];
  const visited = new Set<string>();
  while (current && !visited.has(current.id)) {
    visited.add(current.id);
    x += current.props.x;
    y += current.props.y;
    current = current.parentId ? elements[current.parentId] : undefined;
  }
  return { x, y };
};

export const findNearestContainerId = (elements: Record<string, UIElement>, startId: string | null) => {
  let current = startId ? elements[startId] : undefined;
  const visited = new Set<string>();
  while (current && !visited.has(current.id)) {
    visited.add(current.id);
    if (canAcceptChildren(current.type)) return current.id;
    current = current.parentId ? elements[current.parentId] : undefined;
  }
  return null;
};
